/// Client balance for the dashboard, from open periods only.
class ClientOpenBalance {
  const ClientOpenBalance({
    required this.clientId,
    required this.clientName,
    required this.openPeriodTotal,
    required this.workItemCount,
  });

  final String clientId;
  final String clientName;
  final double openPeriodTotal;
  final int workItemCount;
}
