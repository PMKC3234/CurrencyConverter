//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by PMKC on 28.07.2024.
//


import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cadLabel: UILabel!
    @IBOutlet weak var chfLabel: UILabel!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var jpyLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var tryLabel: UILabel!
    
    // Yükleme animatörü
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Degrade arka plan
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds

        // Canlı renkler için gradient
        let startColor = UIColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1.0).cgColor // Açık turkuaz
        let midColor = UIColor(red: 0.0, green: 0.6, blue: 0.8, alpha: 1.0).cgColor   // Açık mavi
        let endColor = UIColor(red: 0.0, green: 0.4, blue: 0.6, alpha: 1.0).cgColor   // Koyu mavi

        gradientLayer.colors = [startColor, midColor, endColor]
        gradientLayer.locations = [0.0, 0.5, 1.0] // Renk geçiş noktaları

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Etiketler için stil ayarları
        let labels = [cadLabel, chfLabel, gbpLabel, jpyLabel, usdLabel, tryLabel]
        labels.forEach { label in
            label?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
            label?.textColor = UIColor.white // Beyaz renk, degrade üzerinde iyi görünür
            label?.textAlignment = .center
        }
        
        // Etiketleri Stack View içinde düzenle
        let stackView = UIStackView(arrangedSubviews: labels.compactMap { $0 })
        stackView.axis = .vertical
        stackView.spacing = 20 // Boşluk miktarını buradan ayarlayın
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        // Get Rates butonunu özelleştir
        let getRatesButton = UIButton(type: .system)
        getRatesButton.setTitle("Get Rates", for: .normal)
        getRatesButton.setTitleColor(UIColor.white, for: .normal)
        getRatesButton.backgroundColor = UIColor.systemOrange
        getRatesButton.layer.cornerRadius = 10
        getRatesButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        getRatesButton.addTarget(self, action: #selector(getRatesClicked(_:)), for: .touchUpInside)
        
        self.view.addSubview(getRatesButton)
        
        // Yükleme animatörünü ayarla
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        // Stack view pozisyonu
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8)
        ])
        
        // Get Rates butonunun pozisyonu
        getRatesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getRatesButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            getRatesButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            getRatesButton.widthAnchor.constraint(equalToConstant: 200),
            getRatesButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Yükleme animatörünün pozisyonu
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: getRatesButton.topAnchor, constant: -20)
        ])
    }

    @IBAction func getRatesClicked(_ sender: Any) {
        // Yükleme animatörünü başlat
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false // Kullanıcı etkileşimini devre dışı bırak
        
        let url = URL(string:"EXAMPLE APİKEY=1234567890")
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                    // Yükleme animatörünü durdur
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true // Kullanıcı etkileşimini geri getir
                }
            } else {
                if data != nil {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
                        
                        DispatchQueue.main.async {
                            if let rates = jsonResponse["rates"] as? [String: Any] {
                                self.updateLabel(self.cadLabel, withRate: rates["CAD"] as? Double)
                                self.updateLabel(self.chfLabel, withRate: rates["CHF"] as? Double)
                                self.updateLabel(self.gbpLabel, withRate: rates["GBP"] as? Double)
                                self.updateLabel(self.jpyLabel, withRate: rates["JPY"] as? Double)
                                self.updateLabel(self.usdLabel, withRate: rates["USD"] as? Double)
                                self.updateLabel(self.tryLabel, withRate: rates["TRY"] as? Double)
                            }
                            // Yükleme animatörünü durdur
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true // Kullanıcı etkileşimini geri getir
                        }
                    } catch {
                        print("Error")
                        DispatchQueue.main.async {
                            // Yükleme animatörünü durdur
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true // Kullanıcı etkileşimini geri getir
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func updateLabel(_ label: UILabel, withRate rate: Double?) {
        guard let rate = rate else { return }
        label.text = "\(label.text!.prefix(4)) \(rate)"
        
        // Animasyon
        UIView.animate(withDuration: 0.2,
                       animations: {
                           label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.2) {
                               label.transform = CGAffineTransform.identity
                           }
                       })
    }
}

