import 'package:flowledger/core/app_colors.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flutter/material.dart';

String versionStatusLabel(
        AppLocalizations l10n, WorkItemVersionStatus status) =>
    switch (status) {
      WorkItemVersionStatus.draft => l10n.versionStatusDraft,
      WorkItemVersionStatus.sent => l10n.versionStatusSent,
      WorkItemVersionStatus.approved => l10n.versionStatusApproved,
    };

String deliverableStateLabel(AppLocalizations l10n, DeliverableState state) =>
    switch (state) {
      DeliverableState.noVersions => l10n.deliverableNoVersions,
      DeliverableState.draft => l10n.versionStatusDraft,
      DeliverableState.waitingForFeedback => l10n.deliverableWaiting,
      DeliverableState.changesRequested => l10n.deliverableChangesRequested,
      DeliverableState.approved => l10n.versionStatusApproved,
    };

IconData deliverableStateIcon(DeliverableState state) => switch (state) {
      DeliverableState.noVersions => Icons.layers_clear_outlined,
      DeliverableState.draft => Icons.edit_note_outlined,
      DeliverableState.waitingForFeedback => Icons.schedule_send_outlined,
      DeliverableState.changesRequested => Icons.rate_review_outlined,
      DeliverableState.approved => Icons.verified_outlined,
    };

Color deliverableStateColor(ColorScheme colors, DeliverableState state) =>
    switch (state) {
      DeliverableState.noVersions => colors.onSurfaceVariant,
      DeliverableState.draft => colors.onSurfaceVariant,
      DeliverableState.waitingForFeedback => colors.primary,
      DeliverableState.changesRequested => AppColors.warning(colors.brightness),
      DeliverableState.approved => AppColors.success(colors.brightness),
    };

String feedbackKindLabel(AppLocalizations l10n, WorkItemFeedbackKind kind) =>
    switch (kind) {
      WorkItemFeedbackKind.revision => l10n.feedbackKindRevision,
      WorkItemFeedbackKind.newScope => l10n.feedbackKindNewScope,
    };

String feedbackStatusLabel(
        AppLocalizations l10n, WorkItemFeedbackStatus status) =>
    switch (status) {
      WorkItemFeedbackStatus.open => l10n.feedbackStatusOpen,
      WorkItemFeedbackStatus.resolved => l10n.feedbackStatusResolved,
      WorkItemFeedbackStatus.wontDo => l10n.feedbackStatusWontDo,
    };
