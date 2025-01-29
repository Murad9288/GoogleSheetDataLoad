//
//  ViewController.swift
//  GoogleSheetDataLoad
//
//  Created by MD Murad Hossain on 1/30/25.
//

import UIKit
import CoreXLSX
import SwiftCSV

struct Attendee {
    let firstName: String
    let lastName: String
    let company: String
    let state: String
    let email: String
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var data: [Attendee] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TVCell.nib(), forCellReuseIdentifier: TVCell.identifier)
    }

    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.spreadsheet, .commaSeparatedText, .pdf],
            asCopy: true
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    func parseXLSXFile(url: URL) {
        guard let file = XLSXFile(filepath: url.path) else {
            print("Failed to open XLSX file")
            return
        }

        do {
            for path in try file.parseWorksheetPaths() {
                let worksheet = try file.parseWorksheet(at: path)
                var attendees: [Attendee] = []

                if let sharedStrings = try? file.parseSharedStrings(),
                   let rows = worksheet.data?.rows {
                    
                    for row in rows.dropFirst() { // Skip header row
                        let cells = row.cells
                        if cells.count >= 5 {
                            let attendee = Attendee(
                                firstName: cells[0].stringValue(sharedStrings) ?? "",
                                lastName: cells[1].stringValue(sharedStrings) ?? "",
                                company: cells[2].stringValue(sharedStrings) ?? "",
                                state: cells[3].stringValue(sharedStrings) ?? "",
                                email: cells[4].stringValue(sharedStrings) ?? ""
                            )
                            attendees.append(attendee)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.data = attendees
                    print(self.data)

                    self.tableView.reloadData() // ✅ Reload data after update
                }
            }
        } catch {
            print("Error parsing XLSX file: \(error)")
        }
    }

    func parseCSVFile(url: URL) {
        do {
            let csv = try CSV<Named>(url: url)
            var attendees: [Attendee] = []
            
            for row in csv.rows {
                let attendee = Attendee(
                    firstName: row["First Name"] ?? "",
                    lastName: row["Last Name"] ?? "",
                    company: row["Company Name"] ?? "",
                    state: row["State"] ?? "",
                    email: row["Email"] ?? ""
                )
                attendees.append(attendee)
            }
            
            DispatchQueue.main.async { [self] in
                self.data = attendees
                self.tableView.reloadData() // ✅ Reload data after update
            }
            

        } catch {
            print("Error parsing CSV file: \(error)")
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TVCell.identifier, for: indexPath) as! TVCell
        let attendee = data[indexPath.row]
        cell.lblName.text = attendee.firstName + " " + attendee.lastName
        cell.lblEmail.text = attendee.email
        cell.lblDate.text = "30 Jan 2025"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
}

// MARK: - UIDocumentPickerDelegate
extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }

        switch selectedFileURL.pathExtension.lowercased() {
        case "xlsx":
            parseXLSXFile(url: selectedFileURL)
        case "csv":
            parseCSVFile(url: selectedFileURL)
        default:
            print("Unsupported file format")
        }
    }
}
