import json
import time
import chromadb
from tqdm import tqdm
from app.integrations.rag_utils import GeminiEmbeddingFunction

def create_documents(path):
    with open(path, 'r') as f:
        data = json.load(f)

    documents = []
    metadatas = []

    for item in data:
        parts = []

        # (Your existing text building logic remains the same)
        if item.get("guideline"):
            parts.append(f"Guideline: {item['guideline']}")
        if item.get("condition"):
            parts.append(f"Condition: {item['condition']}")
        if item.get("category"):
            parts.append(f"Category: {item['category']}")
        if item.get("gender"):
            parts.append(f"Gender: {item['gender']}")
        if item.get("per_serving_limit"):
            parts.append(f"Per serving limit: {item['per_serving_limit']} {item.get('unit', '')}")
        if item.get("daily_limit"):
            parts.append(f"Daily limit: {item['daily_limit']} {item.get('unit', '')}")
        if item.get("source"):
            parts.append(f"Source: {item['source']}")

        text = ". ".join(parts) + "."
        documents.append(text)

        # --- FIX IS HERE ---
        # ChromaDB crashes on None, so we default to empty strings ""
        metadatas.append({
            "condition": item.get("condition", ""),
            "category": item.get("category", ""),
            "gender": item.get("gender", "both"), # Default to 'both' if missing
            "unit": item.get("unit", ""),         # Default to empty string
            "source": item.get("source", "")
        })

    return documents, metadatas

def create_chroma_db(documents, metadatas, name):
    chroma_client = chromadb.PersistentClient(path="chroma-db/")

    try:
        chroma_client.delete_collection(name=name)
        print(f"Deleted existing collection: {name}")
    except Exception:
        pass

    db = chroma_client.create_collection(
        name=name,
        embedding_function=GeminiEmbeddingFunction()
    )

    print(f"Creating collection: {name}")

    for i, (doc, meta) in tqdm(
        enumerate(zip(documents, metadatas)),
        total=len(documents),
        desc="Creating Chroma DB"
    ):
        db.add(
            documents=[doc],
            metadatas=[meta],
            ids=[str(i)]
        )
        time.sleep(0.5)

    print(f"Total documents stored: {db.count()}")
    return db


import os

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(current_dir, "data", "moodfood.json")
    if not os.path.exists(json_path):
        print(f"Error: File not found at {json_path}")
    else:
        documents, metadatas = create_documents(json_path)
        db_path = os.path.join(current_dir, "chroma-db")
        create_chroma_db(documents, metadatas, name="mood-guidelines")