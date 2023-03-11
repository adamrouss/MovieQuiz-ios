//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by AdamRouss on 07.02.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: () -> Void
}