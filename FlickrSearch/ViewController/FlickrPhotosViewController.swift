/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

enum FlickrConstants {
  static let reuseIdentifier = "FlickrCell"
  static let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  static let itemsPerRow: CGFloat = 3
}

final class FlickrPhotosViewController: UICollectionViewController {
  // MARK: - Properties
  
  //用于选择并分享图片
  var selectedPhotos: [FlickrPhoto] = []
  //现在有多少张图片被选择
  let shareTextLabel = UILabel()
  //controller是否处于分享状态
  var isSharing = false {
    didSet {
      // 1允许选择多个单元格
      collectionView.allowsMultipleSelection = isSharing

      // 2
      collectionView.selectItem(at: nil, animated: true, scrollPosition: [])
      selectedPhotos.removeAll()

      guard let shareButton = navigationItem.rightBarButtonItems?.first else {
        return
      }

      // 3如果不处于分享状态,将button设置为default状态,返回
      // 此时仅设置一个button即可,不用展示文本
       guard isSharing else {
        navigationItem.setRightBarButtonItems([shareButton], animated: true)
        return
      }

      // 4如果此时显示有大图,取消显示
      if largePhotoIndexPath != nil {
        largePhotoIndexPath = nil
      }

      // 5更新label
      updateSharedPhotoCountLabel()

      // 6展示button和文字label
      let sharingItem = UIBarButtonItem(customView: shareTextLabel)
      let items: [UIBarButtonItem] = [
        shareButton,
        sharingItem
      ]

      navigationItem.setRightBarButtonItems(items, animated: true)
    }
  }


  
  
  // 1
  var largePhotoIndexPath: IndexPath? {
    //变量的生命周期函数
    didSet {
      
      //已经选定一张,直接选另一张就需要重新渲染这两张图片
      // 2
      var indexPaths: [IndexPath] = []
      if let largePhotoIndexPath = largePhotoIndexPath {
        indexPaths.append(largePhotoIndexPath)
      }
      //似乎IOS每次重新load都全部重新获取大小,导致下面这段代码有没有效果一样
      if let oldValue = oldValue {
        indexPaths.append(oldValue)
      }

      // 3 collection更新
      collectionView.performBatchUpdates({
        self.collectionView.reloadItems(at: indexPaths)
      }, completion: { _ in
        // 4把选定的滑到中间
        if let largePhotoIndexPath = self.largePhotoIndexPath {
          self.collectionView.scrollToItem(
            at: largePhotoIndexPath,
            at: .centeredVertically,
            animated: true)
        }
      })
    }
  }


  var searches: [FlickrSearchResults] = []
  let flickr = Flickr()
  
  
  
  override func viewDidLoad() {
    //开启drag模式
    super.viewDidLoad()
    collectionView.dragInteractionEnabled = true
    collectionView.dragDelegate = self
    collectionView.dropDelegate = self
  }

  
  
  
  @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
    
    // 1确保不是empty,不然都没有图片可选
    guard !searches.isEmpty else {
      return
    }

    // 2如果没有照片被选,但是按了按钮,就将isSharing取反即可
    guard !selectedPhotos.isEmpty else {
      //切换isSharing的值,取反
      isSharing.toggle()
      return
    }

    // 3
    guard isSharing else {
      return
    }

    // 1创建分享图片集
    let images: [UIImage] = selectedPhotos.compactMap { photo in
      guard let thumbnail = photo.thumbnail else {
        return nil
      }

      return thumbnail
    }

    // 2若空直接返回
    guard !images.isEmpty else {
      return
    }

    // 3
    let shareController = UIActivityViewController(
      activityItems: images,
      applicationActivities: nil)

    // 4
    shareController.completionWithItemsHandler = { _, _, _, _ in
      self.isSharing = false
      self.selectedPhotos.removeAll()
      self.updateSharedPhotoCountLabel()
    }

    // 5弹出分享窗口
    shareController.popoverPresentationController?.barButtonItem = sender
    shareController.popoverPresentationController?.permittedArrowDirections = .any
    present(shareController, animated: true, completion: nil)

    
  }
}


