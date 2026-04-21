import SwiftUI

struct NotificationBannerView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 48)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.vertical, 8)

            HStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                }

                Spacer()
            }
            .padding(12)
        }
        .frame(width: 370)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
