import PackagePlugin

@main
struct MaxwellTCARulesPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let swiftTarget = target as? SwiftSourceModuleTarget else {
            return []
        }

        guard let tool = try? context.tool(named: "MaxwellTCARulesTool") else {
            Diagnostics.error("MaxwellTCARulesTool not found")
            return []
        }

        let excludes = "**/DerivedData/**,**/.build/**,**/Pods/**,**/.swiftpm/**,**/ThirdParty/**,**/Vendor/**,**/External/**"

        return [
            .buildCommand(
                displayName: "Maxwell TCA rules for \(swiftTarget.name)",
                executable: tool.path,
                arguments: ["--exclude", excludes, swiftTarget.directory.string],
                environment: [:],
                inputFiles: swiftTarget.sourceFiles.map { $0.path },
                outputFiles: []
            )
        ]
    }
}
