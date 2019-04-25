import 'dart:math' as math;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class OcclusionPage extends StatefulWidget {
  @override
  _OcclusionPageState createState() => _OcclusionPageState();
}

class _OcclusionPageState extends State<OcclusionPage> {
  ARKitController arkitController;
  ARKitPlane plane;
  ARKitNode node;
  String anchorId;

  @override
  void dispose() {
    arkitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Occlusion Sample')),
        body: Container(
          child: ARKitSceneView(
            showFeaturePoints: true,
            planeDetection: ARPlaneDetection.horizontalAndVertical,
            onARKitViewCreated: onARKitViewCreated,
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (!(anchor is ARKitPlaneAnchor)) {
      return;
    }
    _addPlane(arkitController, anchor);
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor.identifier != anchorId) {
      return;
    }
    final ARKitPlaneAnchor planeAnchor = anchor;
    node.position.value =
        vector.Vector3(planeAnchor.center.x, 0, planeAnchor.center.z);
    plane.width.value = planeAnchor.extent.x;
    plane.height.value = planeAnchor.extent.z;
  }

  void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    anchorId = anchor.identifier;
    plane = ARKitPlane(
      width: anchor.extent.x,
      height: anchor.extent.z,
      materials: [
        ARKitMaterial(
          colorBufferWriteMask: ARKitColorMask.none,
          // transparency: 0.5,
          // diffuse: ARKitMaterialProperty(color: Colors.white),
        )
      ],
    );

    node = ARKitNode(
      geometry: plane,
      renderingOrder: -1,
      position: vector.Vector3(anchor.center.x, 0, anchor.center.z),
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
    );
    controller.add(node, parentNodeName: anchor.nodeName);

    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.physicallyBased,
      diffuse: ARKitMaterialProperty(
        color: Colors.red,
      ),
    );
    final sphere = ARKitSphere(
      materials: [material],
      radius: 0.1,
    );
    final sphereNode = ARKitNode(
      geometry: sphere,
      position: vector.Vector3(0, 0, 0.2),
    );
    controller.add(sphereNode, parentNodeName: node.name);
  }
}