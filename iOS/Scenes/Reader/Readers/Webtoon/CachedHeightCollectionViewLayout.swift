//
//  CachedHeightCollectionViewLayout.swift
//  Aidoku (iOS)
//
//  Created by Skitty on 10/15/22.
//

import UIKit

class CachedHeightCollectionViewLayout: UICollectionViewFlowLayout {

    var cachedHeights: [IndexPath: CGFloat] = [:]

    private var currentAttributes: [UICollectionViewLayoutAttributes] = []

    private var contentSize = CGSize.zero
    override var collectionViewContentSize: CGSize {
        contentSize
    }

    private let estimatedHeight: CGFloat = 300

    override init() {
        super.init()
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        sectionInset = .zero
        estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width, height: estimatedHeight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }

        currentAttributes = []

        var origin: CGFloat = 0
        let width = collectionView.bounds.size.width

        for section in 0..<collectionView.numberOfSections {
            let itemCount = collectionView.numberOfItems(inSection: section)

            for itemIndex in 0..<itemCount {
                let indexPath = IndexPath(item: itemIndex, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                let size = CGSize(width: width, height: cachedHeights[indexPath] ?? estimatedHeight)
                attributes.frame = CGRect(origin: CGPoint(x: 0, y: origin), size: size)
                currentAttributes.append(attributes)

                origin += size.height
            }
        }

        contentSize = CGSize(width: width, height: origin)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        currentAttributes[indexPath.row]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        for item in currentAttributes where rect.intersects(item.frame) {
            attributes.append(item)
        }
        return attributes
    }

    override func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        if let height = cachedHeights[preferredAttributes.indexPath] {
            return originalAttributes.size.height != height
        }
        return preferredAttributes.size.height != originalAttributes.size.height
    }

    override func invalidationContext(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutInvalidationContext {
        let invalidationContext = super.invalidationContext(
            forPreferredLayoutAttributes: preferredAttributes,
            withOriginalAttributes: originalAttributes
        )

        let newHeight = cachedHeights[preferredAttributes.indexPath] ?? preferredAttributes.size.height
        let oldHeight = originalAttributes.size.height

        let oldAdjustment = invalidationContext.contentSizeAdjustment

        invalidationContext.contentSizeAdjustment = CGSize(
            width: oldAdjustment.width,
            height: oldAdjustment.height + newHeight - oldHeight
        )

        return invalidationContext
    }
}
