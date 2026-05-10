# PlayDate iOS App

PlayDate is a dedicated iOS mobile application designed to bridge the gap between digital interaction and physical play.

## Docker Setup (Media Storage)

To store and serve media files locally, we use **MinIO** running in a Docker container.

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.

### 2. Start the Storage Server
Open your terminal in the project root and run:
```bash
docker-compose up -d
```

### 3. Access MinIO Console
Once the container is running, you can manage your files and buckets through the web interface:
- **URL**: [http://localhost:9001](http://localhost:9001)
- **Username**: `minioadmin`
- **Password**: `minioadminpassword`

### 4. Create a Bucket
Before uploading files from the app, you need to create a bucket:
1. Log in to the MinIO Console.
2. Click on **Buckets** -> **Create Bucket**.
3. Name it `playdate-media`.
4. (Optional) Set the Access Policy to **Public** if you want images to be viewable via direct links without authentication.

### 5. App Configuration
The app is configured to connect to `http://localhost:9000` for file operations. 
> **Note**: If testing on a physical device, replace `localhost` with your computer's local IP address.

---

## Development

- **Architecture**: MVVM
- **UI Framework**: SwiftUI
- **Storage**: MinIO (via Docker)
- **Database/Auth**: Firebase (Spark Plan)