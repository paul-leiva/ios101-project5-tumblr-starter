//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// Return the number of rows for the table
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Create, configure and return a table view cell for the given row
        
        /// Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        /// Get the post associated with the TableView row
        let post = posts[indexPath.row]
        
        /// Configure the cell and its elements (photo and caption)
        
        /// Unwrap the optional photo
        if let photo = post.photos.first {
            /// Set the URL
            let photoURL = photo.originalSize.url
            
            /// Load the photo in the ImageView with Nuke library
            Nuke.loadImage(with: photoURL, into: cell.postImage)
        }
        
        
        /// Get the row where the cell will be placed using the `row` property from the `indexPath`
        cell.postSummary.text = post.summary
        
        return cell
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()

        
        fetchPosts()
        tableView.dataSource = self
    }

    /// Setup TableView UI Outlet
    @IBOutlet weak var tableView: UITableView!
    
    /// Add property to store the fetched `Posts` array
    /// Providing a default value of an empty array avoids having to deal with optionals
    private var posts: [Post] = []


    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                        print("📷 Photo URLs: \(post.photos)")
                    }
                    
                    /// Store posts in the `posts` property on the ViewController (so we can access the data anywhere in the View Controller)
                    self?.posts = posts
                    
                    /// Reload the data in the TableView with the fetched Posts
                    self?.tableView.reloadData()
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
