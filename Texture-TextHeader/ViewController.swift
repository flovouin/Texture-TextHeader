//
//  ViewController.swift
//  Texture-TextHeader
//
//  Created by Flo Vouin on 03/01/2018.
//  Copyright © 2018 flovouin. All rights reserved.
//

import AsyncDisplayKit

/**
    Steps to reproduce the bug:
        - Run the app.
        - Swipe to the second page.
        - Put the app in the background.
        - Bring the app to the foreground.
        - Swipe to the first page.

    -> The text in the header has disappeared.
*/

class ViewController: ASViewController<ASPagerNode>, ASPagerDataSource {
    // MARK: - Lifecycle
    init() {
        super.init(node: ASPagerNode())

        self.node.setDataSource(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ASPagerDataSource
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 2
    }

    func pagerNode(_ pagerNode: ASPagerNode, nodeBlockAt index: Int) -> ASCellNodeBlock {
        switch index {
        case 0:
            return { CollectionAndHeaderCellNode() }
        case 1:
            return {
                let node = ASCellNode()
                node.backgroundColor = .red
                return node
            }
        default:
            return { ASCellNode() }
        }
    }
}

class CollectionAndHeaderCellNode: ASCellNode, ASCollectionDataSource {
    let collectionNode: ASCollectionNode

    // MARK: - Lifecycle
    override init() {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 100.0, height: 100.0)
        self.collectionNode = ASCollectionNode(collectionViewLayout: layout)

        super.init()

        self.collectionNode.dataSource = self

        self.addSubnode(self.collectionNode)
    }

    override func didLoad() {
        super.didLoad()

        self.collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    }

    // MARK: - Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: self.collectionNode)
    }

    // MARK: - ASCollectionDataSource
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        supplementaryElementKindsInSection section: Int) -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> ASCellNodeBlock {
        return { HeaderCell() }
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let node = ASTextCellNode()
            node.text = String(indexPath.item)
            node.backgroundColor = .blue
            return node
        }
    }
}

class HeaderCell: ASCellNode {
    let textNode = ASTextNode()

    override init() {
        super.init()

        self.backgroundColor = .green
        self.textNode.attributedText = NSAttributedString(string: "Oh hi!")
        self.addSubnode(self.textNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: self.textNode)
    }

    override func didEnterVisibleState() {
        super.didEnterVisibleState()

        // This works around the problem.
//        self.textNode.setNeedsDisplay()
    }
}
