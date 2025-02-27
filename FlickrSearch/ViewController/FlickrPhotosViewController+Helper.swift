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

extension FlickrPhotosViewController {
  func photo(for indexPath: IndexPath) -> FlickrPhoto {
    return searches[indexPath.section].searchResults[indexPath.row]
  }
  
  func removePhoto(at indexPath: IndexPath) {
    searches[indexPath.section].searchResults.remove(at: indexPath.row)
  }

  func insertPhoto(_ flickrPhoto: FlickrPhoto, at indexPath: IndexPath) {
    searches[indexPath.section].searchResults.insert(
      flickrPhoto,
      at: indexPath.row)
  }

  
  
  func performLargeImageFetch(
    for indexPath: IndexPath,
    flickrPhoto: FlickrPhoto,
    cell: FlickrPhotoCell
  ) {
    // 1开始表示加载的动画
    cell.activityIndicator.startAnimating()

    // 2调用加载图片函数,结束之后执行闭包里面的内容
    //[]表示捕获,以弱引用捕获self
    flickrPhoto.loadLargeImage { [weak self] result in
      cell.activityIndicator.stopAnimating()

      // 3因为是弱引用,所以得先确保self存在
      guard let self = self else {
        return
      }

      switch result {
      // 4
      case .success(let photo):
        //如果是选中的图片,因为当一张大图下载好时可能已经选择了另一张图片,判断是否需要更新当前cell为大图版
        if indexPath == self.largePhotoIndexPath {
          cell.imageView.image = photo.largeImage
        }
      case .failure:
        return
      }
    }
  }

  func updateSharedPhotoCountLabel() {
    if isSharing {
      shareTextLabel.text = "\(selectedPhotos.count) photos selected"
    } else {
      shareTextLabel.text = ""
    }

    shareTextLabel.textColor = themeColor

    UIView.animate(withDuration: 0.3) {
      self.shareTextLabel.sizeToFit()
    }
  }

  
}
