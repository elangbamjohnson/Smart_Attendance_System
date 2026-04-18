# Smart Attendance System

## Face Recognition & Attendance System

### Core Features

- Real-time face detection with bounding boxes
- Tap-to-recognize functionality
- Face cropping with smart padding
- Face recognition using Core ML (FaceNet model)
- Automatic attendance marking
- Persistent storage of known faces
- Voice feedback support

## 1. App Launch & Camera Setup
- `CameraViewModel` is initialized  
- `CameraService.startSession()` is called  
- Camera starts capturing frames in real-time  
- `StorageService` loads saved faces (`faces.json`) into memory  

## 2. Frame Capture Pipeline
- Each camera frame is received as a `CVPixelBuffer`  
- Frame is passed via `cameraService.onFrameCaptured`  
- Inside ViewModel:
  - `currentPixelBuffer` is updated  
  - Frame is sent to `FaceDetectionService`  

## 3. Face Detection (Vision Framework)
- `FaceDetectionService.detectFaces()` is called  
- Uses `VNDetectFaceRectanglesRequest`  
- Returns `VNFaceObservation` array  

### ViewModel
- Converts observations into bounding boxes (`CGRect`)  
- Updates:
```swift
@Published var faceBoxes: [CGRect]
```
UI
	•	Draws bounding boxes on detected faces in real-time

## 4. User Interaction (Tap on Face)
	•	User taps on the screen
	•	handleTap():
	◦	Converts normalized coordinates to screen space
	◦	Checks if tap is inside any face box
	•	If matched:

captureFace(from: box)

## 5. Face Cropping
	•	Uses currentPixelBuffer
Steps:
	•	Convert normalized bounding box → pixel coordinates
	•	Make bounding box square
	•	Add padding (~30%)
	•	Clamp to image bounds
Output:
	•	Cropped UIImage
Next:

handleCapturedFace(image)

## 6. Face Recognition (Core ML)
Step 1: Feature Extraction
	•	Convert image → MLMultiArray
	•	Pass into Facenet model
	•	Output: embedding vector [Float]

getEmbedding(from: image)

Step 2: Compare with Stored Faces
	•	Loop through:

storageService.savedFaces

	•	For each face:

cosineSimilarity(newEmbedding, storedEmbedding)

Step 3: Decision
	•	If:

similarity > 0.6

→ Recognized ✅
	•	Else → Unknown ❌
## 7. Recognition Result Handling
Known Face
	•	Update UI:

recognizedName = "<name> marked present"
showRecognitionBanner = true

	•	Call:

markAttendance(name)

	•	Voice:

Welcome <name>

Unknown Face
	•	Store:

capturedFace = image

	•	Show input UI:

showNameInput = true

	•	Message:

New Face Detected

	•	Voice:

Face not recognized. Please register.

## 8. Save New Face
Step 1: Generate Embedding

getEmbedding(from: image)

Step 2: Save Image
	•	Path:

/Documents/faces/<UUID>.png

Step 3: Create Person Model

struct Person {
    let id: UUID
    let name: String
    let embedding: [Float]
    let imagePath: String
}

Step 4: Persist Data
	•	Append to:

savedFaces

	•	Save to:

faces.json

## 9. Persistence (App Restart)
	•	On launch:

StorageService.loadSavedFaces()

	•	Reads:

faces.json

	•	Restores:

savedFaces

## 10. Recognition on Next Scan
	•	Capture new face
	•	Generate embedding
	•	Compare with:

savedFaces (loaded from disk)

	•	Matching uses:

cosine similarity

## 11. Attendance Tracking
Model:

struct AttendanceRecord {
    let id: UUID
    let name: String
    let date: Date
}

Stored in:

attendanceRecords

## 12. Cancel Flow

capturedFace = nil
showNameInput = false
recognizedName = ""
showRecognitionBanner = false
speechService.reset()
