/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    let coachingOverlay = ARCoachingOverlayView()
    let objectManager = MultiObjectManager()
    var isRestartAvailable = true

    // MARK: - View Life Cycle

    /// - Tag: StartARSession
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        sceneView.delegate = self

        objectManager.sceneView = sceneView
        // Set a delegate to track the number of plane anchors for providing UI feedback.
//        sceneView.session.delegate = self

        UIApplication.shared.isIdleTimerDisabled = true

        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true

        setupCoachingOverlay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's AR session.
        sceneView.session.pause()
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        objectManager.addObjects()
    }

    @IBAction func arTapped(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: sceneView)
        objectManager.selectObject(at: touchLocation)
    }

    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func restartExperience() {
//        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
//        isRestartAvailable = false
//        virtualObjectLoader.removeAllVirtualObjects()

        resetTracking()

        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
//            self.upperControlsView.isHidden = false
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        objectManager.addPlane(node: node, anchor: planeAnchor)
    }

    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        if let planeAnchor = anchor as? ARPlaneAnchor, let plane = node.childNodes.first as? Plane {
            objectManager.updatePlane(plane: plane, anchor: planeAnchor)
        }
    }
}

//extension ViewController: ARSessionDelegate {
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//           guard let frame = session.currentFrame else { return }
//           updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
//       }
//
//       func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
//           guard let frame = session.currentFrame else { return }
//           updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
//       }
//
//       func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
//           updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
//       }
//}
