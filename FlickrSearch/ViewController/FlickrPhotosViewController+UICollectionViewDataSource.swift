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
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return searches.count
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return searches[section].searchResults.count
  }

  
  //应该对每个位置的单元格都调用一次
  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    //获取重用单元格
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: FlickrConstants.reuseIdentifier,
      for: indexPath) as? FlickrPhotoCell
    else {
      preconditionFailure("Invalid cell type")
    }
    //获取该路径照片,以section和index区分
    let flickrPhoto = photo(for: indexPath)

    // 1 当一个大图正在加载,这时选择另一个图片,重新渲染时就需要将这个大图的加载动画停止
    // select一张图即发生更新
    cell.activityIndicator.stopAnimating()

    // 2当前图片是否是被选中应该放大的图片
    guard indexPath == largePhotoIndexPath else {
      cell.imageView.image = flickrPhoto.thumbnail
      return cell
    }

    // 3检查largeimage是否已经下载
    cell.isSelected = true
    guard flickrPhoto.largeImage == nil else {
      cell.imageView.image = flickrPhoto.largeImage
      return cell
    }

    // 4先显示正常图放大版,然后加载大图
    cell.imageView.image = flickrPhoto.thumbnail

    // 5下载大图片,开启动画,异步下载
    performLargeImageFetch(for: indexPath, flickrPhoto: flickrPhoto, cell: cell)

    //先直接return cell,已经配置了正常图放大版,下载好大图后,会在回调函数里面更新
    return cell
  }

  
  override func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    switch kind {
    // 1
    case UICollectionView.elementKindSectionHeader:
      // 2
      let headerView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: "\(FlickrPhotoHeaderView.self)",
        for: indexPath)

      // 3
      guard let typedHeaderView = headerView as? FlickrPhotoHeaderView
      else { return headerView }

      // 4
      let searchTerm = searches[indexPath.section].searchTerm
      typedHeaderView.titleLabel.text = searchTerm
      return typedHeaderView
    default:
      // 5
      assert(false, "Invalid element type")
    }
  }

}


