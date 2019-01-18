//
//  RoundedVisualEffecView.swift
//  AnimalClassifierML
//
//  Created by gdm on 1/17/19.
//  Copyright © 2019 gdm. All rights reserved.
//

import UIKit

class RoundedVisualEffecView: UIVisualEffectView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        self.clipsToBounds = true
    }

}
