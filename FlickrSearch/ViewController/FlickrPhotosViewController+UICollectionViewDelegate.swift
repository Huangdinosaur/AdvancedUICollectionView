


import UIKit

extension FlickrPhotosViewController {
  override func collectionView(
    _ collectionView: UICollectionView,
    shouldSelectItemAt indexPath: IndexPath
  ) -> Bool {
    
    //处于分享状态选择照片,无需更改largePhotoIndexPath,不需要做任何事
    guard !isSharing else {
      return true
    }

    
    // 1,说明取消选择
    if largePhotoIndexPath == indexPath {
      largePhotoIndexPath = nil
    } else {
      //选择
      largePhotoIndexPath = indexPath
    }

    // 2
    return false
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    guard isSharing else {
      return
    }

    let flickrPhoto = photo(for: indexPath)
    selectedPhotos.append(flickrPhoto)
    updateSharedPhotoCountLabel()
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath
  ) {
    guard isSharing else {
      return
    }

    let flickrPhoto = photo(for: indexPath)
    if let index = selectedPhotos.firstIndex(of: flickrPhoto) {
      selectedPhotos.remove(at: index)
      updateSharedPhotoCountLabel()
    }
  }

  
  
}
