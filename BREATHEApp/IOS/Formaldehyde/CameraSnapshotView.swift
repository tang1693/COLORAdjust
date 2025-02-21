import SwiftUI
import Vision
import AVFoundation
import AudioToolbox
import UserNotifications

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

struct DeferView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()          // << everything is created here
    }
}

struct CameraSnapshotView: View{
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var camera = CameraModel()
    @State private var selection: Int?
    let TIMEOUT: Int = 3
    @State private var timeRemaining: Int = 3
    let timer = Timer.publish(every: 0.5, on: .main, in: .default).autoconnect()
    @State private var isImageTaken: Bool = false
    @ObservedObject var newTestData: NewTestData
    var flag: Bool

    init(newTestData: NewTestData, flag: Bool){
        self.flag = flag
        self.newTestData = newTestData
    }
    
    func takePhoto(){
        AudioServicesPlaySystemSound(1108)
        self.camera.session.stopRunning()
        self.camera.imageWarpped_rotate = OpenCVWrapper.warpImage(from: self.camera.imageFrame!, with: self.camera.imageK!)
        self.camera.imageWarpped = OpenCVWrapper.colorAdjustment(from: self.camera.imageWarpped_rotate!, with: self.camera.stdImage!)
        if self.flag == true{
            newTestData.imageBoardBefore = self.camera.imageWarpped
            newTestData.imageFrameBefore = self.camera.imageFrame
        }
        else{
            newTestData.imageBoardAfter = self.camera.imageWarpped
            newTestData.imageFrameAfter = self.camera.imageFrame
        }
        self.selection = 1
        self.isImageTaken.toggle()
    }
    
    var body: some View{
        ZStack{
            Image(uiImage: camera.imageProcessed ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
            if self.camera.imageStatus{
                Text(String(timeRemaining))
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(90))
            }
            VStack {
                Spacer()
                ZStack {
                    NavigationLink(destination:
                                    ImageSaveView(newTestData: self.newTestData, flag: self.flag, camera: self.camera)
                                    .navigationTitle("BREATHE-Smart")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .navigationBarBackButtonHidden(true)
                                   , isActive: $isImageTaken){
                        EmptyView()}
                    Button(action: takePhoto)
                    {
                        ZStack{
                            Circle()
                                .frame(width:60, height:60)
                                .foregroundColor(.white)
                            Circle()
                                .stroke(lineWidth: 3)
                                .frame(width:70, height:70)
                                .foregroundColor(.white)
                        }
                    }.padding(64)
                }
            }
        }
        .onAppear(perform: {
            print(newTestData.imagesaved)
            if newTestData.imagesaved == true {
                newTestData.imagesaved = false
                if newTestData.imageBoardAfter == nil {
                    newTestData.starttime = Date()
                    newTestData.timeremaining = 30
                }
                presentationMode.wrappedValue.dismiss()
            }
            camera.check()
            camera.session.startRunning()
        })
        .onChange(of: self.camera.imageStatusReset, perform: { value in
            if value == true{
                self.timeRemaining = TIMEOUT
                print("Reset")
            }
        })
        .onReceive(timer) { time in
            print("Timeout", self.timeRemaining, self.camera.imageStatus, self.camera.imageStatusReset, self.selection ?? 0)
            if self.selection == nil, self.camera.imageStatus {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                }else{
                    self.timeRemaining = TIMEOUT
                    self.takePhoto()
                }
            }
        }
    }
}

struct ImageSaveView: View{
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var camera : CameraModel
    @ObservedObject var newTestData: NewTestData
    var flag: Bool
    @State private var isImageSaved: Bool = false
    let imageSaver = ImageSaver()
    let dateformatter = DateFormatter()
    @State private var time: String = ""
    
    init(newTestData: NewTestData, flag: Bool, camera: CameraModel){
        self.flag = flag
        self.newTestData = newTestData
        self.camera = camera
        dateformatter.dateFormat = "MMMM dd, yyyy. hh:mm a"
    }
    
    var body: some View{
        VStack{
            Image(uiImage: self.camera.imageWarpped_rotate!)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image(uiImage: self.camera.imageWarpped!)
                .resizable()
                .aspectRatio(contentMode: .fit)
            HStack{
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Retake")
                        .bold()
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                }
                Spacer()
                Button {
                    imageSaver.writeToPhotoAlbum(image: self.camera.imageWarpped!)
                    self.time = dateformatter.string(from: newTestData.starttime)
                    self.newTestData.imagesaved.toggle()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save")
                        .bold()
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                }
            }
        }.onAppear{
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

class CameraModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    // frame counter
    var frameCnt:UInt64 = 0
    @Published var imageFrame: UIImage? = nil
    @Published var imageProcessed: UIImage? = nil
    @Published var imageK: matrix_float3x3? = nil
    @Published var imageStatus: Bool = false
    @Published var imageStatusReset: Bool = false
    @Published var imageWarpped: UIImage? = nil
    @Published var imageWarpped_rotate: UIImage? = nil
    @Published var stdImage: UIImage? = nil

    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var photoOutput = AVCapturePhotoOutput()
    @Published var videoOutput = AVCaptureVideoDataOutput()
    
    override init()
    {
        super.init()
        OpenCVWrapper.initFrameProcessor()
        
        stdImage = UIImage(named: "stdboard",
                           in: Bundle(for: type(of:self)),
                           compatibleWith: nil)
        print("OpenCVWrapper initialized.")
    }
    func check(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){
                (status) in
                if status {
                    self.setup()
                }
            }
        case .denied:
            self.alert.toggle()
        default:
            return
        }
    }
    func setup() {
        do{
            self.session.beginConfiguration()
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.photoOutput){
                self.session.addOutput(self.photoOutput)
                print("Photo output added")
            }
            
            if self.session.canAddOutput(self.videoOutput){
                self.videoOutput.videoSettings =
                    [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.processing.queue"))
                
                self.session.addOutput(self.videoOutput)
                
                guard let connection = self.videoOutput.connection(with: AVMediaType.video),
                      connection.isVideoOrientationSupported else { return }
                connection.videoOrientation = .portrait
                
                // Enable Intrinsic
                if connection.isCameraIntrinsicMatrixDeliverySupported {
                    connection.isCameraIntrinsicMatrixDeliveryEnabled = true
                    print("Intrinsic Enabled")
                }
                
                print("Video output added")
            }
            self.session.commitConfiguration()
        }catch{
            print(error.localizedDescription)
        }
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        // get KMat
        var KMat:matrix_float3x3?
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) as? Data {
            KMat = camData.withUnsafeBytes{ $0.load(as: matrix_float3x3.self) }
                if self.frameCnt<1 {
                    print(KMat!)
                }
            }
        
        // convert the camera frame bitmap into an UIImage
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        let context = CGContext(data: baseAddress, width: width, height: height,
                               bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        guard let quartzImage = context?.makeImage() else { return }
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        let image = UIImage(cgImage: quartzImage)
        
        // process the frame
        let processResult = OpenCVWrapper.detectPattern(from: image, with: KMat!) as NSDictionary
        
        // tell the main queue(worker) to display the image to user
        DispatchQueue.main.async{
            self.imageFrame = image
            self.imageProcessed = processResult["image"] as? UIImage
            let newStatus = processResult["status"] as! Bool
            self.imageStatusReset = self.imageStatus == false && newStatus
            self.imageStatus = newStatus
            self.imageK = KMat
        }
        self.frameCnt += 1
    }
}

