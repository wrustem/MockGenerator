//
//  MockGeneratorService.swift
//  MockGenerator
//
//  Created by Rustem Sayfullin on 16.12.2024.
//

import Foundation

struct MockGeneratorService {
    
    let methodRegex = #"func\s+(\w+)\s*\(([\s\S]*?)\)\s*(->\s*([\w<>\[\]:\s\?]+))?(?=\s*\n\s*func|\s*\n\s*\})"#
    let propertyRegex = #"var\s+(\w+)\s*:\s*([\w<>\[\]:\s\?]+)"#
    
    func generateMock(from protocolCode: String) -> String {
        guard let protocolNameMatch = protocolCode.range(of: #"protocol\s+(\w+)"#, options: .regularExpression) else {
            return "Error: Could not find protocol name."
        }
        
        let protocolName = String(protocolCode[protocolNameMatch]).components(separatedBy: " ").last!

        let methodsMatches = matches(for: methodRegex, in: protocolCode)
        let propertiesMatches = matches(for: propertyRegex, in: protocolCode)

        var properties = ""
        var methods = ""

        for prop in propertiesMatches {
            if let propName = prop[1], let propType = prop[2] {
                properties += "    var \(propName): \(propType)\n"
            }
        }

        for match in methodsMatches {
            if let methodName = match[1] {
                let parameters = match[2]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let returnType = match[4]?.trimmingCharacters(in: .whitespacesAndNewlines)

                let parsedParameters = parseParameters(methodName: methodName, parameters: parameters)
                properties += parsedParameters.properties
                
                // Добавление returnValue переменной
                if let returnType = returnType, returnType != "Void" {
                    properties += "    var \(methodName)ReturnValue: \(returnType)?\n"
                }

                let returnHandling = generateReturnValueHandling(methodName: methodName, returnType: returnType)
                let returnTypeString = returnType != nil ? " -> \(returnType!)" : ""

                methods += """
    func \(methodName)(\(parameters))\(returnTypeString) {
        \(parsedParameters.callCountProperty) += 1\(parsedParameters.argumentCaptures)\(returnHandling)
    }\n\n
"""
            }
        }

        return """
class \(protocolName)Mock: \(protocolName) {

\(properties)

\(methods)}
"""
    }

    private func matches(for regex: String, in text: String) -> [[String?]] {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, range: range)
        return matches.map { match in
            (0..<match.numberOfRanges).map {
                let range = match.range(at: $0)
                guard let rangeInString = Range(range, in: text) else { return nil }
                return String(text[rangeInString])
            }
        }
    }

    private func parseParameters(methodName: String, parameters: String) -> (properties: String, callCountProperty: String, argumentCaptures: String) {
        // Свойство для подсчета вызовов
        let callCountProperty = "\(methodName)CallCount"
        var properties = "    var \(callCountProperty) = 0\n"
        var argumentCaptures = ""
        
        guard !parameters.isEmpty else {
            return (properties, callCountProperty, argumentCaptures)
        }
        
        let params = parameters
            .split(separator: ",")
            .map { parseSingleParameter($0) }
        
        // Генерация свойств и аргументов
        for (name, type) in params {
            let propertyName = "\(methodName)\(capitalizeFirstLetter(name))"
            properties += "    var \(propertyName): \(type)\n"
            argumentCaptures += "\n        \(propertyName) = \(name)"
        }
        
        return (properties, callCountProperty, argumentCaptures)
    }

    //Парсинга одного параметра
    private func parseSingleParameter(_ param: Substring) -> (String, String) {
        let cleanedParam = param
            .split(separator: "=", maxSplits: 1)
            .first?
            .trimmingCharacters(in: .whitespaces) ?? ""
        
        let parts = cleanedParam
            .split(separator: ":", maxSplits: 1)
            .map { String($0).trimmingCharacters(in: .whitespaces) }
        
        let fullName = parts[0]
        let internalName = fullName.split(separator: " ").last.map { String($0) } ?? fullName
        let paramType = parts.count > 1 ? parts[1] : "Void"
        
        // Убираем лишний уровень опциональности
        return (internalName, ensureOptionalType(paramType))
    }

    // Чтобы стал опционалом
    private func ensureOptionalType(_ type: String) -> String {
        return type.hasSuffix("?") ? type : "\(type)?"
    }

    private func generateReturnValueHandling(methodName: String, returnType: String?) -> String {
        guard let returnType = returnType, returnType != "Void" else { return "" }
        return """
\n        guard let returnValue = \(methodName)ReturnValue else {
            fatalError("ReturnValue for \(methodName) not set")
        }
        return returnValue
"""
    }

    private func capitalizeFirstLetter(_ text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
}
