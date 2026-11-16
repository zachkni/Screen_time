import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Customises the screen shown when you open a blocked app or website.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private func makeConfiguration(name: String?) -> ShieldConfiguration {
        let title = name.map { "\($0) is blocked" } ?? "This is blocked"
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.10, green: 0.08, blue: 0.22, alpha: 1),
            icon: UIImage(systemName: "hourglass"),
            title: ShieldConfiguration.Label(text: title, color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "You set this limit for a reason.\nPut the phone down for a bit.",
                color: UIColor.white.withAlphaComponent(0.8)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: .systemIndigo
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration(name: application.localizedDisplayName)
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(name: application.localizedDisplayName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration(name: webDomain.domain)
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(name: webDomain.domain)
    }
}
