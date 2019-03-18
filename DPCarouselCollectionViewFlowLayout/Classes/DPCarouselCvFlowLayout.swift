//
//  DPCarouselCvFlowLayout.swift
//  DPCarouselCollectionViewFlowLayout
//
//  Created by Xueqiang Ma on 18/3/19.
//
//  Inspired by https://github.com/ink-spot/UPCarouselFlowLayout.
//

import UIKit

open class DPCarouselCvFlowLayout: UICollectionViewFlowLayout {
    fileprivate let sideItemAlpha: CGFloat = 0.4
    fileprivate let sideItemScale: CGFloat = 0.6
    
    open override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {return}
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        let xPadding = (collectionView.bounds.width - itemSize.width) / 2.0
        let yPadding = (collectionView.bounds.height - itemSize.height) / 2.0
        
        // set "sectionInset" and "minimumLineSpacing"
        itemSize = CGSize(width: 300, height: 100)
        if scrollDirection == .horizontal {
            sectionInset = UIEdgeInsets(top: yPadding, left: xPadding, bottom: yPadding, right: xPadding)
            minimumLineSpacing = -itemSize.width * 0.3
        } else {
            sectionInset = UIEdgeInsets(top: yPadding, left: xPadding, bottom: yPadding, right: xPadding)
            minimumLineSpacing = -itemSize.height * 0.3
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
        var closest: UICollectionViewLayoutAttributes!
        var offset: CGPoint!
        if scrollDirection == .horizontal {
            let middle = collectionView.bounds.width / 2.0
            let proposedCenter = proposedContentOffset.x + middle
            let cellShiftOffset = collectionView.bounds.width / 2.0 - itemSize.width
            closest = attributesList.sorted {
                abs($0.center.x + cellShiftOffset - proposedCenter) < abs($1.center.x + cellShiftOffset - proposedCenter)
                }.first ?? UICollectionViewLayoutAttributes()
            offset = CGPoint(x: closest.center.x + cellShiftOffset - middle,
                             y: proposedContentOffset.y)
        } else {
            let middle = collectionView.bounds.height / 2.0
            let proposedCenter = proposedContentOffset.y + middle
            let cellShiftOffset = collectionView.bounds.height / 2.0 - itemSize.height
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
        var cvCenter: CGFloat = 0.0
        var normalizedCenter: CGFloat = 0.0
        var maxDistance: CGFloat = 0.0
        if scrollDirection == .horizontal {
            cvCenter = collectionView.bounds.width / 2.0  // collection view center
            normalizedCenter = attributes.center.x - collectionView.contentOffset.x // cell center
            maxDistance = collectionView.bounds.width / 1.5
        } else {
            cvCenter = collectionView.bounds.height / 2.0  // collection view center
            normalizedCenter = attributes.center.y - collectionView.contentOffset.y // cell center
            maxDistance = collectionView.bounds.height / 1.5
        }
        let distance = min(abs(cvCenter - normalizedCenter), maxDistance)
        let progress = (maxDistance - distance) / maxDistance   // cell to cv center's progress
        let alpha = progress * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = sideItemScale + progress * (1 - sideItemScale)
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 1000)
        if scrollDirection == .horizontal {
            attributes.center.x -= collectionView.bounds.width / 2.0 - itemSize.width
        } else {
            attributes.center.y -= collectionView.bounds.height / 2.0 - itemSize.height
        }
        return attributes
    }
}
