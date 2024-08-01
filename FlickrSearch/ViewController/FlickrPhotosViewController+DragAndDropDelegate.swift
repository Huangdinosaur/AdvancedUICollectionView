



import UIKit

// MARK: - UICollectionViewDragDelegate
extension FlickrPhotosViewController: UICollectionViewDragDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    itemsForBeginning session: UIDragSession,
    at indexPath: IndexPath
  ) -> [UIDragItem] {
    // 1获取被选中的UIImage对象
    let flickrPhoto = photo(for: indexPath)
    guard let thumbnail = flickrPhoto.thumbnail else {
      return []
    }

    // 2提供被drag的对象
    let item = NSItemProvider(object: thumbnail)

    // 3呈现被drag的对象
    let dragItem = UIDragItem(itemProvider: item)

    // 4返回被drag对象数组集合
    return [dragItem]
  }
}


extension FlickrPhotosViewController: UICollectionViewDropDelegate {
  
  func collectionView(
    _ collectionView: UICollectionView,
    performDropWith coordinator: UICollectionViewDropCoordinator
  ) {
    // 1获取目标路径
    guard let destinationIndexPath = coordinator.destinationIndexPath else {
      return
    }

    // 2确保每个item都有source
    coordinator.items.forEach { dropItem in
      guard let sourceIndexPath = dropItem.sourceIndexPath else {
        return
      }

      // 3更新
      collectionView.performBatchUpdates({
        
        //放下才执行
        //print("执行update。。。\(Date().timeIntervalSince1970)")
        let image = photo(for: sourceIndexPath)
        //更新数据源
        removePhoto(at: sourceIndexPath)
        insertPhoto(image, at: destinationIndexPath)
        //更新对应的是视图
        collectionView.deleteItems(at: [sourceIndexPath])
        collectionView.insertItems(at: [destinationIndexPath])
      }, completion: { _ in
        // 4执行下放动作
        coordinator.drop(
          dropItem.dragItem,
          toItemAt: destinationIndexPath)
      })
    }
  }

  
  func collectionView(
    _ collectionView: UICollectionView,
    canHandle session: UIDropSession
  ) -> Bool {
    //这个决定了UICollection里面的图片会自动移动以适应图片的拖动位置
    //图片自动移动应该是UICollection本身实现的
    return true
  }
  
  
  func collectionView(
    _ collectionView: UICollectionView,
    dropSessionDidUpdate session: UIDropSession,
    withDestinationIndexPath destinationIndexPath: IndexPath?
  ) -> UICollectionViewDropProposal {
    return UICollectionViewDropProposal(
      operation: .move,
      intent: .insertAtDestinationIndexPath)
  }

  
}

