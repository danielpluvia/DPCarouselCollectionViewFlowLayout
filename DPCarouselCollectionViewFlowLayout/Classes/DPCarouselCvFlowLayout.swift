//
//  DPCarouselCvFlowLayout.swift
//  DPCarouselCollectionViewFlowLayout
//
//  Created by Xueqiang Ma on 18/3/19.
//
//  Inspired by https://github.com/ink-spot/UPCarouselFlowLayout
//

import UIKit

open class DPCarouselCvFlowLayout: UICollectionViewFlowLayout {
    fileprivate let sideItemAlpha: CGFloat = 0.4
    fileprivate let sideItemScale: CGFloat = 0.6
    
    fileprivate let cellSize = CGSize(width: 300.0, height: 100.0)
    
    open override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {return}
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        
        let availableBounds = collectionView.bounds.inset(by: collectionView.layoutMargins)
        itemSize = CGSize(width: cellSize.width, height: cellSize.height)
        
        let xPadding = (availableBounds.width - itemSize.width - collectionView.contentInset.left - collectionView.contentInset.right) / 2.0
        let yPadding = (availableBounds.height - itemSize.height - collectionView.contentInset.left - collectionView.contentInset.right) / 2.0
        sectionInset = UIEdgeInsets(top: yPadding, left: xPadding, bottom: yPadding, right: xPadding)
        if #available(iOS 11.0, *) {
            sectionInsetReference = .fromSafeArea
        } else {
            // Fallback on earlier versions
        }
        
        if scrollDirection == .horizontal {
            minimumLineSpacing = -itemSize.width * 0.4
        } else {
            minimumLineSpacing = -itemSize.height * 0.4
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributesList = super.layoutAttributesForElements(in: rect),
            let attributesList = NSArray(array: superAttributesList, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        return attributesList.map{ transform(attributes: $0) }
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView,
            let attributesList = self.layoutAttributesForElements(in: collectionView.bounds) else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        let availableBounds = collectionView.bounds.inset(by: collectionView.layoutMargins)
        var closest: UICollectionViewLayoutAttributes!
        var offset: CGPoint!
        if scrollDirection == .horizontal {
            let middle = availableBounds.width / 2.0
            let proposedCenter = proposedContentOffset.x + middle
            let cellShiftOffset = availableBounds.width / 2.0 - itemSize.width
            closest = attributesList.sorted {
                abs($0.center.x + cellShiftOffset - proposedCenter) < abs($1.center.x + cellShiftOffset - proposedCenter)
                }.first ?? UICollectionViewLayoutAttributes()
            offset = CGPoint(x: closest.center.x + cellShiftOffset - middle,
                             y: proposedContentOffset.y)
        } else {
            let middle = availableBounds.height / 2.0
            let proposedCenter = proposedContentOffset.y + middle
            let cellShiftOffset = availableBounds.height / 2.0 - itemSize.height
            closest = attributesList.sorted {
                abs($0.center.y + cellShiftOffset - proposedCenter) < abs($1.center.y + cellShiftOffset - proposedCenter)
                }.first ?? UICollectionViewLayoutAttributes()
            offset = CGPoint(x: proposedContentOffset.x,
                             y: closest.center.y + cellShiftOffset - middle)
        }
        return offset
    }
}

extension DPCarouselCvFlowLayout {
    fileprivate func transform(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView else {return attributes}
        let availableBounds = collectionView.bounds.inset(by: collectionView.layoutMargins)
        var cvCenter: CGFloat = 0.0
        var normalizedCenter: CGFloat = 0.0
        var maxDistance: CGFloat = 0.0
        if scrollDirection == .horizontal {
            cvCenter = availableBounds.width / 2.0  // collection view center
            normalizedCenter = attributes.center.x - collectionView.contentOffset.x // cell center
            maxDistance = availableBounds.width / 1.5
        } else {
            cvCenter = availableBounds.height / 2.0  // collection view center
            normalizedCenter = attributes.center.y - collectionView.contentOffset.y // cell center
            maxDistance = availableBounds.height / 1.5
        }
        let distance = min(abs(cvCenter - normalizedCenter), maxDistance)
        let progress = (maxDistance - distance) / maxDistance   // cell to cv center's progress
        let alpha = progress * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = sideItemScale + progress * (1 - sideItemScale)
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 1000)
        if scrollDirection == .horizontal {
            attributes.center.x -= availableBounds.width / 2.0 - itemSize.width
        } else {
            attributes.center.y -= availableBounds.height / 2.0 - itemSize.height
        }
        return attributes
    }
}
