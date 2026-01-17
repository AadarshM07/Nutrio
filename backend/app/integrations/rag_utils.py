import os
from dotenv import load_dotenv
import pandas as pd
import chromadb
from google import genai
from chromadb import Documents, EmbeddingFunction, Embeddings

load_dotenv()

api_key= os.getenv("GEMINI_API")
client = genai.Client(api_key=api_key)


class GeminiEmbeddingFunction(EmbeddingFunction):
    def __init__(self):
        pass
    
    def __call__(self, input: Documents) -> Embeddings:
        embeddings = []
        for text in input:
            result = client.models.embed_content(
                model='models/text-embedding-004',
                contents=text
            )
            embeddings.append(result.embeddings[0].values)
        return embeddings

def get_relevant_passages(db, query, n_results=5, max_distance=0.8):
    results = db.query(
        query_texts=[query],
        n_results=n_results
    )
    passages = []

    for i in range(len(results["documents"][0])):
        distance = results["distances"][0][i]   
        content = results["documents"][0][i]
        metadata = results["metadatas"][0][i]
        doc_id = results["ids"][0][i]

        if distance <= max_distance:
            passages.append({
                "id": doc_id,
                "content": content,
                "relevance_score": distance,
                "metadata": metadata
            })

    return passages


def get_chroma_db(name):
    chroma_client = chromadb.PersistentClient(path="chroma-db/")
    return chroma_client.get_collection(name=name, embedding_function=GeminiEmbeddingFunction())

if __name__== "__main__":
    db = get_chroma_db("disease-guidelines")
    query = "How much sugar can a Cholestrole person consume daily?"
    results = get_relevant_passages(query, db, n_results=3)
    for res in results:
        print(res)