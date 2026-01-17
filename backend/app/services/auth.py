from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from datetime import datetime, timedelta
import bcrypt
import os

# SQLModel specific imports
from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession

from app.models import User
from app.database import get_session
from app.schemas.auth import RegisterRequest, LoginRequest, UserResponse, Token, SurveyRequest

router = APIRouter()

# SECURITY WARNING: Move this to an environment variable in production
SECRET_KEY = os.environ.get("SECRET_KEY", "super_secret_key_default") 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 3000000

# --- Helper Functions ---
def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_password(plain_password, hashed_password):
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def get_password_hash(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')


# --- Routes ---

@router.post("/register/", response_model=UserResponse, status_code=201)
async def register_user(request: RegisterRequest, db: AsyncSession = Depends(get_session)):
    # Async query using select()
    statement = select(User).where(User.email == request.email)
    result = await db.exec(statement)
    existing_user = result.first()
    
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_pwd = get_password_hash(request.password)
    
    new_user = User(
        name=request.name,
        email=request.email,
        password_hash=hashed_pwd
    )
    
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    
    return new_user

@router.post("/login/", response_model=Token)
async def login(request: LoginRequest, db: AsyncSession = Depends(get_session)):
    # Async query
    statement = select(User).where(User.email == request.email)
    result = await db.exec(statement)
    user = result.first()

    if not user or not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(data={"sub": str(user.id)})
    return {
        "access_token": access_token,
        "token_type": "bearer",
    }

# --- Dependencies for Protected Routes ---

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login") # Note the URL path

async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_session)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    # Async query to get user by ID
    statement = select(User).where(User.id == int(user_id))
    result = await db.exec(statement)
    user = result.first()
    
    if user is None:
        raise credentials_exception
    return user


@router.post("/submit-survey/", response_model=UserResponse)
async def submit_survey(
    survey_data: SurveyRequest,
    current_user: User = Depends(get_current_user), # Handles Auth
    db: AsyncSession = Depends(get_session)
):
    """
    Updates the current authenticated user's profile with survey data.
    Only updates fields that are actually provided (not None).
    """
    
    # Update fields if they are provided in the request
    if survey_data.weight is not None:
        current_user.weight = survey_data.weight
    if survey_data.height is not None:
        current_user.height = survey_data.height
    if survey_data.gender is not None:
        current_user.gender = survey_data.gender
    if survey_data.health_issues is not None:
        current_user.health_issues = survey_data.health_issues
    if survey_data.dietary_preferences is not None:
        current_user.dietary_preferences = survey_data.dietary_preferences
    if survey_data.goals is not None:
        current_user.goals = survey_data.goals
    if survey_data.health_details is not None:
        current_user.health_details = survey_data.health_details

    db.add(current_user)
    await db.commit()
    await db.refresh(current_user)
    
    return current_user


@router.get("/me/", response_model=UserResponse)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user