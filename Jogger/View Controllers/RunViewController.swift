//
//  RunViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-05-23.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class RunViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var startRunButton: UIButton!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var currentSpeedText: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var refUsers:DatabaseReference!
    var refRuns:DatabaseReference!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var startLocation = CLLocation()
    var lastLocation:CLLocation?
    var speed = CLLocationSpeed()
    
    var run:Run?
    var speedArray:[Double] = []
    var averageSpeeds = 0.0

    //Location Manager inits
    let locationManager = CLLocationManager()
    let montreal = CLLocation(latitude: 45.5016889, longitude: -73.56725599999999)
    
    var loadingView:UIActivityIndicatorView!
    
    var totalDistance:Double = 0.0
    var pace = 0.0
    
    var timer = Timer()
    var intCounter = 0
    var btnClick = true
    
    var date:String = ""
    
    var runPicture:UIImage?
    
    //LocationList array for updating locations on map
    var locationList: [CLLocation] = []
    var polylineList:[MKPolyline] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //try! Auth.auth().signOut()
        
        self.title = "Jogger"
        
        if UIScreen.main.bounds.height == 568 {
            heightConstraint.constant = 300
        }
        
        self.refUsers = Database.database().reference().child("user")
        self.refRuns = Database.database().reference().child("runs")
        
        //set buttons look
        startRunButton.backgroundColor = UIColor(red: 0.1, green: 0.74, blue: 0.35, alpha: 1)
        startRunButton.setTitle("START", for: .normal)
        startRunButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        startRunButton.layer.cornerRadius = startRunButton.frame.height/2
        
        pauseButton.layer.cornerRadius = pauseButton.frame.height/2
        pauseButton.isHidden = true
        
        leftView.layer.borderWidth = 1
        leftView.layer.borderColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1).cgColor
        rightView.layer.borderWidth = 1
        rightView.layer.borderColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1).cgColor

        
        //Map
        self.map.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        map.showsPointsOfInterest = false
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestLocation()
        }
        
        loadingView = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 20, y: self.view.frame.height/2, width: 40, height: 40))
        loadingView.activityIndicatorViewStyle = .whiteLarge
        loadingView.color = UIColor.black
        view.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isUserLoggedIn() == false {
            performSegue(withIdentifier: "showLoginVC", sender: self)
        } else {
            self.fetchData()
            self.loadRuns()
        }
        
        if self.appDelegate.unitKm == false {
            self.distanceText.text = NSLocalizedString("Distance (miles)", comment: "Distance (miles)")
            self.currentSpeedText.text = NSLocalizedString("Current Speed (mph)", comment: "Current Speed (mph)")
        } else if self.appDelegate.unitKm == true {
            self.distanceText.text = NSLocalizedString("Distance (km)", comment: "Distance (km)")
            self.currentSpeedText.text = NSLocalizedString("Current Speed (km/h)", comment: "Current Speed (km/h)")
        }
    
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        loadingView.stopAnimating()
        //Set map
        var currentLocation = locations[0] as CLLocation
        for location in locations {
            if location.verticalAccuracy < 0 || location.horizontalAccuracy < 0 {
                currentLocation = locations.last!
            }
        }
        //Radius in Meters
        let regionRadius: CLLocationDistance = 1000
        //Define Region
        let coordinateRegion: MKCoordinateRegion!
        if TARGET_OS_SIMULATOR == 1 {
            //Create a Map region
            coordinateRegion = MKCoordinateRegionMakeWithDistance(montreal.coordinate,regionRadius, regionRadius)
        }
        else{
            //WE ARE ON A DEVICE
            //Create a Map region
            coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, regionRadius, regionRadius)
        }
        //set mapView to the region specified
        map.setRegion(coordinateRegion, animated: true)
     
        //Add locations to locationList to add polyline
        locationList.append(locations[0] as CLLocation)
        
        if btnClick == true {
            map.showsUserLocation = true
        } else {
            map.showsUserLocation = false
        }
        
        if (locationList.count > 1){
            let startIndex = locationList.count - 1
            let endIndex = locationList.count - 2
            
            let c1 = locationList[startIndex].coordinate
            let c2 = locationList[endIndex].coordinate
            let polylineLocation = [c1, c2]
            let polyline = MKPolyline(coordinates: polylineLocation, count: polylineLocation.count)
            polylineList.append(polyline)
            map.add(polyline)
        }
        
        //DISTANCE & SPEED
        speed = (locationManager.location?.speed)!
        if lastLocation == nil {
            print("first location")
            lastLocation = locations.first!
        } else {
            print("last location")
            let userLocation = locationManager.location
            var previousDistance = userLocation?.distance(from: lastLocation!)
            previousDistance = previousDistance! * 0.001
            totalDistance += previousDistance!
                if speed > 0 {
                    if self.appDelegate.unitKm == true {
                        speedLabel.text = String(format: "%.2f", speed * 3.6)
                    } else if self.appDelegate.unitKm == false {
                        speed = speed * 3.6
                        speed = speed/0.621371
                        speedLabel.text = String(format: "%.2f", speed)
                    }
                } else {
                    if self.appDelegate.unitKm == true {
                        speed = (userLocation?.distance(from: lastLocation!))! / (userLocation?.timestamp.timeIntervalSince((lastLocation?.timestamp)!))!
                        speedLabel.text = String(format: "%.2f", speed)
                    } else if self.appDelegate.unitKm == false {
                        speed = (userLocation?.distance(from: lastLocation!))! / (userLocation?.timestamp.timeIntervalSince((lastLocation?.timestamp)!))!
                        speed = speed/0.621371
                        speedLabel.text = String(format: "%.2f", speed)
                    }
                }
            speedArray.append(speed)
            lastLocation = locations.last!
        }
        if self.appDelegate.unitKm == true {
            distanceLabel.text = String(format: "%.2f", totalDistance)
        } else if self.appDelegate.unitKm == false{
            totalDistance = totalDistance/0.621371
            distanceLabel.text = String(format: "%.2f", totalDistance)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("We failed to get your current Location")
    }
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func startButton(_ sender: Any) {
        if btnClick == true {
            startLocationUpdates()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.displayAnnotations(locations: self.locationList)
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                self.btnClick = false
            }
            pauseButton.isHidden = false
            startRunButton.setTitle(NSLocalizedString("FINISH", comment: "FINISH"), for: .normal)
           
        }
        else {
            displayAnnotations(locations: locationList)
            timer.invalidate()
            pauseButton.isHidden = true
            locationManager.stopUpdatingLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.saveRun()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.startRunButton.setTitle(NSLocalizedString("START", comment: "START"), for: .normal)
                self.btnClick = true
                self.locationList = []
                self.intCounter = 0
                self.runTime.text! = String("00:00:00")
                self.distanceLabel.text! = String("0.00")
                self.speedLabel.text! = String("00.00")
                self.totalDistance = 0.0
                self.pace = 0.0
                for overlay in self.map.overlays{
                    self.map.remove(overlay)
                }
                for annotation in self.map.annotations {
                    self.map.removeAnnotation(annotation)
                }
                self.map.showsUserLocation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.appDelegate.segueFromTableView = false
                self.performSegue(withIdentifier: "showRunDetailVC", sender: self)
            }
        }
        
    }
    @IBAction func pause(_ sender: Any) {
        if pauseButton.currentImage == #imageLiteral(resourceName: "pause"){
            pauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            timer.invalidate()
        }
        else {
            pauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimer() {
        intCounter += 1
        
        runTime.text! = String(format: "%02d:%02d:%02d", intCounter / 3600, (intCounter % 3600) / 60, (intCounter % 3600) % 60)
    }
    
    //MARK: - Location Updates
    func startLocationUpdates(){
        locationManager.delegate = self
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Save Run
    func saveRun(){
        takePictureOfRun()
        getDate()
        let runDuration = String(intCounter)
        let runDate = date
        //calculate average speed
        for speed in speedArray{
            averageSpeeds += speed
        }
        let avgSpeed = averageSpeeds/Double(speedArray.count)
        let runSpeed = String(format: "%.2f", avgSpeed)
        let runDistance = self.distanceLabel.text
        //calculate pace
        var runPace:String
        guard let runTime = runTime.text else { return }
        let runTimeDouble = Double(runTime)
        guard let distance = distanceLabel.text else { return }
        let distanceDouble = Double(distance)
        if distanceDouble != nil && runTimeDouble != nil {
            let pace = (distanceDouble! / runTimeDouble!)
            runPace = String(pace)
        }
        else { runPace = "0"
        }
        let id = self.refRuns.childByAutoId().key
        
        let run = Run(runId: id, runDuration: runDuration, runDate: runDate, runImage: nil, runSpeed: runSpeed, runPace: runPace, runDistance: runDistance!)
        print("appending run")
        appDelegate.runHistoryList.append(run)
        
        let data = [
            "runId": run.runId,
            "runDuration": run.runDuration,
            "runDate": run.runDate,
            "runImage": "",
            "runSpeed" : run.runSpeed,
            "runPace": run.runPace,
            "runDistance": run.runDistance
            ] as [String : Any?]
        
        
        self.refRuns.child((Auth.auth().currentUser?.uid)!).child("run").child(run.runId).setValue(data)
        let imageData = UIImageJPEGRepresentation(runPicture!, 0.8)
        let storageRef = Storage.storage().reference().child("runImages").child((Auth.auth().currentUser?.uid)!).child(run.runId)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) { (strMetaData, error) in
            if error == nil {
                print("Image Uploaded Successfully")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error uploading image: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func getDate(){
        let currentDate = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        formatter.string(from: currentDate)
        
        date = formatter.string(from: currentDate)
    }
    
    func takePictureOfRun(){
        startRunButton.isHidden = true
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.viewWithTag(10)?.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        print("appending image")
        self.appDelegate.snapshotArray.append(image)
        runPicture = image
        startRunButton.isHidden = false
    }
    
    //MARK: - Polylines
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = self.appDelegate.colorChoice
            polylineRenderer.lineWidth = 8
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
    //MARK: - User Login
    func isUserLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil{
            return true
        } else {
            return false
        }
    }
    
    func fetchData(){
        self.refUsers.child((Auth.auth().currentUser?.uid)!).observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.appDelegate.users.removeAll()
                
                for users in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let userObject = users.value as? [String:AnyObject]
                    let userName = userObject?["name"]
                    let userId = userObject?["id"]
                    let userLocation = userObject?["location"]
                    
                    //creating user object with model and fetched vaclues
                    print("user")
                    let user = User(id: (userId as! String?)!, image: nil, name: (userName as! String?)!, location: (userLocation as! String?)!)
                    
                    //appending it to list
                    self.appDelegate.users.append(user)
                }
            }
        }
    }
    
    func loadRuns(){
        self.refRuns.child((Auth.auth().currentUser?.uid)!).child("run").observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.appDelegate.runHistoryList.removeAll()
                print("snapshot.childrenCount : \(snapshot.childrenCount)")
                for runs in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let runObject = runs.value as? [String: String]
                    let runId  = runObject?["runId"]
                    let runDuration  = runObject?["runDuration"]
                    let runDate  = runObject?["runDate"]
                    let runSpeed = runObject?["runSpeed"]
                    let runPace = runObject?["runPace"]
                    let runDistance = runObject?["runDistance"]
                    
                    //creating artist object with model and fetched values
                    let run = Run(runId: (runId)!,
                                  runDuration: (runDuration)!,
                                  runDate: (runDate)!,
                                  runImage: nil,
                                  runSpeed: (runSpeed)!,
                                  runPace: (runPace)!,
                                  runDistance: (runDistance)!)
                    self.appDelegate.runHistoryList.append(run)
                    
                    
                }
                print("runs appended")
            }
        }
    }
    
    func displayAnnotations(locations:[CLLocation]){
        if btnClick == true {
            print("DISPLAY ANNOTATIONS TRUE")
            let startLocation = locations.first
            let start = CLLocationCoordinate2D(latitude: (startLocation?.coordinate.latitude)!, longitude: (startLocation?.coordinate.longitude)!)
            let startAnnotation = StartAnnotation()
            startAnnotation.coordinate = start
            
            self.map.addAnnotation(startAnnotation)
        } else {
            print("DISPLAY ANNOTATIONS FALSE")
            let endLocation = locations.last
            let end = CLLocationCoordinate2D(latitude: (endLocation?.coordinate.latitude)!, longitude: (endLocation?.coordinate.longitude)!)
            let endAnnotation = StopAnnotation()
            endAnnotation.coordinate = end
            
            self.map.addAnnotation(endAnnotation)
        }
       
    }
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        var aView:MKAnnotationView!
        
        if annotation.isKind(of: MKUserLocation.self){
            return nil
        }
        if annotation.isKind(of: StartAnnotation.self){
            print("VIEWFOR START")
            reuseId = "start"
            aView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if aView == nil {
                aView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                aView?.frame = CGRect(x: 0, y: 0, width: (UIImage(named: "startFlag")?.size.width)!, height: (UIImage(named: "startFlag")?.size.height)!)
                
                aView!.image = UIImage(named: "startFlag")
            }
        }
        if annotation.isKind(of: StopAnnotation.self){
            print("VIEWFOR FINISH")
            reuseId = "finish"
            aView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if aView == nil {
                aView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                aView?.frame = CGRect(x: 0, y: 0, width: (UIImage(named: "finishFlag")?.size.width)!, height: (UIImage(named: "finishFlag")?.size.height)!)
                
                aView!.image = UIImage(named: "finishFlag")
            }
        }
        return aView
    }
}





