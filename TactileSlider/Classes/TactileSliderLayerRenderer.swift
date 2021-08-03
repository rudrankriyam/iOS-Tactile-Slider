//
//  TactileSliderLayerRenderer.swift
//  TactileSlider
//
//  Created by Dale Price on 1/26/19.
//

import UIKit

internal class TactileSliderLayerRenderer {
	
	private static var valueChangeTimingFunction = CAMediaTimingFunction(name: .default)
	
	weak var tactileSlider: TactileSlider?
	
	var trackBackground: UIColor = .darkGray {
		didSet {
			trackLayer.backgroundColor = trackBackground.cgColor
		}
	}
	
	var outlineSize: CGFloat = 3 {
		didSet {
			updateOutlineLayer()
		}
	}
	
	var thumbTint: UIColor = .white {
		didSet {
			thumbLayer.fillColor = thumbTint.cgColor
		}
	}
	
	var cornerRadius: CGFloat = 10 {
		didSet {
			updateMaskLayerPath()
		}
	}
	
	var grayedOut: Bool = false {
		didSet {
			updateGrayedOut()
		}
	}
	
	var popUp: Bool = false {
		didSet(oldValue) {
			if oldValue != popUp {
				updatePopUp()
			}
		}
	}
	
	let trackLayer = CAShapeLayer()
	let thumbLayer = CAShapeLayer()
	let maskLayer = CAShapeLayer()
	
	init() {
		trackLayer.backgroundColor = trackBackground.cgColor
		trackLayer.fillColor = UIColor.clear.cgColor
		thumbLayer.fillColor = thumbTint.cgColor
		maskLayer.fillColor = UIColor.white.cgColor
		maskLayer.backgroundColor = UIColor.clear.cgColor
		trackLayer.mask = maskLayer
		trackLayer.masksToBounds = true
		
		updateOutlineColors()
		updateOutlineLayer()
	}
	
	private func updateThumbLayerPath() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		thumbLayer.path = CGPath(rect: CGRect(x: 0, y: 0, width: thumbLayer.bounds.width, height: thumbLayer.bounds.height), transform: nil)
		
		CATransaction.commit()
	}
	
	private func updateMaskLayerPath() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		let maskRect = CGRect(x: 0, y: 0, width: maskLayer.bounds.width, height: maskLayer.bounds.height)
		let maskPath = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius)
		maskLayer.path = maskPath.cgPath
		
		trackLayer.path = maskPath.cgPath
		
		CATransaction.commit()
	}
	
	internal func updateOutlineColors() {
		let color: CGColor?
		if let slider = tactileSlider {
			color = slider.outlineColorProvider(slider)?.cgColor
		} else {
			color = nil
		}
		
		trackLayer.strokeColor = color
		thumbLayer.borderColor = color
	}
	
	private func updateOutlineLayer() {
		trackLayer.lineWidth = outlineSize
		thumbLayer.borderWidth = outlineSize / 2
	}
	
	private func updateGrayedOut() {
		let alpha: Float = grayedOut ? 0.6 : 1
		trackLayer.opacity = alpha
	}
	
	private func updatePopUp() {
		CATransaction.begin()
		
		CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
		CATransaction.setAnimationDuration(0.1)
		
		let zPosition: CGFloat = popUp ? 1.025 : 1
		trackLayer.transform = CATransform3DScale(CATransform3DIdentity, zPosition, zPosition, zPosition)
		
		CATransaction.commit()
	}
	
	internal func updateBounds(_ bounds: CGRect) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		trackLayer.bounds = bounds
		trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
		
		maskLayer.bounds = trackLayer.bounds
		maskLayer.position = trackLayer.position
		updateMaskLayerPath()
		
		thumbLayer.bounds = trackLayer.bounds
		thumbLayer.position = trackLayer.position
		updateThumbLayerPath()
		
		CATransaction.commit()
		
		if let value = tactileSlider?.value {
			setValue(value)
		}
	}
	
	internal func setValue(_ value: Float, animated: Bool = false) {
		CATransaction.begin()
		
		if animated {
			CATransaction.setAnimationTimingFunction(Self.valueChangeTimingFunction)
		} else {
			CATransaction.setDisableActions(true)
		}
		
		let valueAxisOffset = tactileSlider!.valueAxisFrom(CGPoint(x: thumbLayer.bounds.width, y: thumbLayer.bounds.height), accountForDirection: true)
		let valueAxisAmount = tactileSlider!.positionForValue(value)
		let reverseOffset = (tactileSlider!.reverseValueAxis && !tactileSlider!.vertical) || (!tactileSlider!.reverseValueAxis && tactileSlider!.vertical)
		let position = tactileSlider!.pointOnSlider(valueAxisPosition: valueAxisAmount - (reverseOffset ? 0 : valueAxisOffset), offAxisPosition: 0)
		
		thumbLayer.transform = CATransform3DTranslate(CATransform3DIdentity, position.x, position.y, 0)
		
		CATransaction.commit()
	}
}
