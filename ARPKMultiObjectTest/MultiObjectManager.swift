//
//  MultiObjectManager.swift
//  ARPKMultiObjectTest
//
//  Created by Gerald Kim on 8/6/20.
//  Copyright © 2020 ARPlaykit. All rights reserved.
//

import ARKit

class MultiObjectManager {

    weak var sceneView: ARSCNView!
    var planes: [Plane] = []
    var objects: [SCNNode] = []

    var selectedObject: SCNNode?

    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        // Create a custom object to visualize the plane geometry and extent.
        let plane = Plane(anchor: anchor, in: sceneView)

        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
        planes.append(plane)
    }

    func updatePlane(plane: Plane, anchor: ARPlaneAnchor) {

        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: anchor.geometry)
        }

        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(anchor.extent.x)
            extentGeometry.height = CGFloat(anchor.extent.z)
            plane.extentNode.simdPosition = anchor.center
        }

        // Update the plane's classification and the text position
        if let classificationNode = plane.classificationNode,
            let classificationGeometry = classificationNode.geometry as? SCNText {
            let currentClassification = anchor.classification.description
            plane.classificationType = anchor.classification
            if let oldClassification = classificationGeometry.string as? String, oldClassification != currentClassification {
                classificationGeometry.string = currentClassification
                classificationNode.centerAlign()
            }
        }
    }

    func addObjects() {
        planes.forEach { plane in
            switch plane.classificationType {
            case .wall:
                let cube = makeCube(color: .red)
                cube.centerAlign()
                plane.addChildNode(cube)
                objects.append(cube)
            case .floor:
                let cube = makeCube(color: .blue)
                cube.centerAlign()
                plane.addChildNode(cube)
                objects.append(cube)
            case .seat:
                let cube = makeCube(color: .yellow)
                cube.centerAlign()
                plane.addChildNode(cube)
                objects.append(cube)
            default:
                let cube = makeCube(color: .gray)
                cube.centerAlign()
                plane.addChildNode(cube)
                objects.append(cube)
            }
        }
    }

    func selectObject(at point: CGPoint) {
        guard objects.count > 0 else { return }
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        guard let selected = sceneView.hitTest(point, options: hitTestOptions).first?.node else { return }
        if objects.contains(selected) {
            selectedObject = selected

            guard let material = selected.geometry?.firstMaterial else { return }
            material.diffuse.contents = UIColor.white
        }
    }

    func makeCube(color: UIColor) -> SCNNode {
        let geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        guard let material = geometry.firstMaterial else {
            fatalError("SCNBox always has one material")
        }
        material.diffuse.contents = color
        return SCNNode(geometry: geometry)
    }
}
