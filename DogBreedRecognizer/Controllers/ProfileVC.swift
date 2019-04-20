
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Floaty
import FirebaseStorage

enum DogCategory: String {
    case lost = "Lost"
    case found = "Found"
}

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DogDelegate {

    
    //Outlets
    @IBOutlet weak var usernameOutlet: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var floaty: Floaty!
    @IBOutlet weak var userImage: UIImageView!
    //Variables
    private var dogs = [Dog]()
    private var dogsCollectionRef: CollectionReference!
    private var dogsListener: ListenerRegistration!
    private var selectedCategory = DogCategory.lost.rawValue
    //Constants
    let userDefault = UserDefaults.standard
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImage.layer.cornerRadius = 90
        userImage.clipsToBounds = true
        floaty.addItem(title: "Lost Dog", handler: {_ in
            self.performSegue(withIdentifier: "GoToLostDogVC" , sender: self)
        })
        floaty.addItem(title: "Found dog", handler: {_ in
            self.performSegue(withIdentifier: "GoToFoundDogVC" , sender: self)
        })
        floaty.addItem(title: "Recognize", handler: {_ in
            self.performSegue(withIdentifier: "GoToRecognizeDogVC" , sender: self)
        })
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        //        guard let email = Auth.auth().currentUser?.email else { return }

        dogsCollectionRef = Firestore.firestore().collection(DOGS_REF)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setListener()
        
        guard let username = Auth.auth().currentUser?.displayName else { return }
        usernameOutlet.text = "\(username)"
        
        guard let imageURL = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let httpsReference = storage.reference(forURL: imageURL)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.userImage.image = image
            }
        }
    }
    
    func setListener() {
        dogsListener = dogsCollectionRef
            .whereField(CATEGORY, isEqualTo: selectedCategory)
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    debugPrint("Error fetching documents \(error)")
                } else {
                    self.dogs.removeAll()
                    self.dogs = Dog.parseData(snapshot: snapshot)
                    self.tableView.reloadData()
                }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if dogsListener != nil {
            dogsListener.remove()
        }
    }
    
    //protocol method for the optionsMenu
    func dogOptionMenuTapped(dog: Dog) {
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete your dog?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            //delete the dog
            Firestore.firestore().collection(DOGS_REF).document(dog.documentId).delete(completion: { (error) in
                if let error = error {
                    debugPrint("Error deleteing the dog \(error.localizedDescription)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as? DogCell {
            cell.configureCell(dog: dogs[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToCommentsVC", sender: dogs[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToCommentsVC" {
            if let destinationVC = segue.destination as? CommentsVC {
                if let dog = sender as? Dog {
                    destinationVC.dog = dog
                }
            }
        }
    }
    
    //Actions
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectedCategory = DogCategory.lost.rawValue
        default:
            selectedCategory = DogCategory.found.rawValue
        }
        if dogsListener != nil {
            dogsListener.remove()
        }
        setListener()
    }
    
}

