import os
import io
from PIL import Image
from supabase import create_client, Client

# --- SUPABASE CONFIG ---
# Replace these with your actual keys from Supabase Project Settings > API
SUPABASE_URL = "https://fqmevrwgnlnublaicuzo.supabase.co"
SUPABASE_KEY = "sb_secret_bnjCwqrZrfdzYNIU3FK6LQ_jR-zqpKk"
BUCKET_NAME = "media"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
INPUT_DIR = "e:/Flutter projects/High-Performance-Feed/high_performance_feed/lib/backend/input_images"

def upload_to_storage(path, file_bytes):
    try:
        # The content-type is set to image/webp because of the conversion logic below
        supabase.storage.from_(BUCKET_NAME).upload(
            path, 
            file_bytes, 
            {"content-type": "image/webp"}
        )
    except Exception as e:
        print(f"Skipping upload for {path} (might already exist or check permissions).")

def process_and_upload():
    if not os.path.exists(INPUT_DIR):
        print(f"Create a folder named '{INPUT_DIR}' and add some images.")
        return

    for filename in os.listdir(INPUT_DIR):
        if not filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            continue

        filepath = os.path.join(INPUT_DIR, filename)
        base_name = os.path.splitext(filename)[0]
        print(f"Processing: {filename}...")

        with Image.open(filepath) as img:
            # 1. Raw Archive (Original)
            raw_bytes = io.BytesIO()
            img.save(raw_bytes, format=img.format)
            raw_path = f"{base_name}_raw.{img.format.lower()}"

            # 2. Mobile Full (1080x1080 max)
            mobile_img = img.copy()
            mobile_img.thumbnail((1080, 1080), Image.Resampling.LANCZOS)
            mobile_bytes = io.BytesIO()
            mobile_img.save(mobile_bytes, format="webp", quality=80)
            mobile_path = f"{base_name}_mobile.webp"

            # 3. Thumbnail (300x300 max)
            thumb_img = img.copy()
            thumb_img.thumbnail((300, 300), Image.Resampling.LANCZOS)
            thumb_bytes = io.BytesIO()
            thumb_img.save(thumb_bytes, format="webp", quality=70)
            thumb_path = f"{base_name}_thumb.webp"

            # Upload to Supabase Storage
            upload_to_storage(raw_path, raw_bytes.getvalue())
            upload_to_storage(mobile_path, mobile_bytes.getvalue())
            upload_to_storage(thumb_path, thumb_bytes.getvalue())

            # Get Public URLs
            raw_url = supabase.storage.from_(BUCKET_NAME).get_public_url(raw_path)
            mobile_url = supabase.storage.from_(BUCKET_NAME).get_public_url(mobile_path)
            thumb_url = supabase.storage.from_(BUCKET_NAME).get_public_url(thumb_path)

            # Insert into Database
            supabase.table("posts").insert({
                "media_thumb_url": thumb_url,
                "media_mobile_url": mobile_url,
                "media_raw_url": raw_url,
            }).execute()

            print(f"Successfully seeded {filename} to database.\n")

if __name__ == "__main__":
    process_and_upload()
    print("Pipeline complete.")