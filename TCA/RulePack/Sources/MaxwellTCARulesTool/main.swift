import Foundation
import SmithValidation
import SmithValidationCore
import MaxwellsTCARules

// Default excludes to avoid scanning build artifacts and vendored deps.
let defaultExcludes = ["**/DerivedData/**", "**/.build/**", "**/Pods/**", "**/.swiftpm/**", "**/ThirdParty/**", "**/Vendor/**", "**/External/**"]

struct Args {
    let targetPath: String
    let exclude: [String]
}

func parseArgs() -> Args? {
    var target: String?
    var exclude: [String] = defaultExcludes
    var it = CommandLine.arguments.dropFirst().makeIterator()
    while let arg = it.next() {
        switch arg {
        case "--exclude":
            if let next = it.next() {
                exclude = next.split(separator: ",").map(String.init)
            }
        default:
            if target == nil { target = arg }
        }
    }
    guard let t = target else { return nil }
    return Args(targetPath: t, exclude: exclude)
}

func emitError(file: String, line: Int, message: String) {
    // Emit in the format the compiler will surface as an error.
    print("\(file):\(line): error: \(message)")
}

func main() {
    guard let args = parseArgs() else {
        fputs("usage: MaxwellTCARulesTool [--exclude globs] <targetPath>\n", stderr)
        exit(1)
    }

    do {
        let urls = try FileUtils.findSwiftFiles(
            in: URL(fileURLWithPath: args.targetPath),
            includeGlobs: ["**/*.swift"],
            excludeGlobs: args.exclude
        )
        let filePaths = urls.map { $0.path }
        let rules = registerMaxwellsRules()
        let engine = ValidationEngine()
        let violations = try engine.validate(rules: rules, filePaths: filePaths)

        for v in violations.violations {
            emitError(file: v.file, line: v.line, message: "\(v.rule): \(v.message)")
        }
    } catch {
        fputs("MaxwellTCARulesTool failed: \(error)\n", stderr)
        exit(1)
    }
}

main()
