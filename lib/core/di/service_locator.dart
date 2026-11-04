import 'package:get_it/get_it.dart';

import '../../features/ai_feedback/application/get_ai_feedback_summary_use_case.dart';
import '../../features/ai_feedback/application/get_my_ai_feedback_use_case.dart';
import '../../features/ai_feedback/application/submit_ai_feedback_use_case.dart';
import '../../features/ai_feedback/infrastructure/ai_feedback_api.dart';
import '../../features/ai_feedback/presentation/ai_feedback_history_view_model.dart';
import '../../features/auth/application/forgot_password_use_case.dart';
import '../../features/auth/application/google_auth_use_case.dart';
import '../../features/auth/application/sign_in_use_case.dart';
import '../../features/auth/application/sign_up_use_case.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/infrastructure/auth_api.dart';
import '../../features/auth/infrastructure/auth_repository_impl.dart';
import '../../features/auth/presentation/forgot_password_view_model.dart';
import '../../features/auth/presentation/login_view_model.dart';
import '../../features/auth/presentation/register_view_model.dart';
import '../../features/chat/application/get_conversation_messages_use_case.dart';
import '../../features/chat/application/get_conversations_use_case.dart';
import '../../features/chat/application/send_message_use_case.dart';
import '../../features/chat/application/start_conversation_use_case.dart';
import '../../features/chat/domain/chat_repository.dart';
import '../../features/chat/infrastructure/chat_api.dart';
import '../../features/chat/infrastructure/chat_repository_impl.dart';
import '../../features/chat/presentation/chat_view_model.dart';
import '../../features/habits/application/create_habit_use_case.dart';
import '../../features/habits/application/delete_habit_use_case.dart';
import '../../features/habits/application/get_habit_logs_use_case.dart';
import '../../features/habits/application/get_habit_suggestions_use_case.dart';
import '../../features/habits/application/get_habits_use_case.dart';
import '../../features/habits/application/toggle_habit_today_use_case.dart';
import '../../features/habits/domain/habits_repository.dart';
import '../../features/habits/infrastructure/habits_api.dart';
import '../../features/habits/infrastructure/habits_repository_impl.dart';
import '../../features/habits/presentation/habit_suggestions_view_model.dart';
import '../../features/habits/presentation/habits_view_model.dart';
import '../../features/insights/application/export_report_use_case.dart';
import '../../features/insights/application/get_dashboard_use_case.dart';
import '../../features/insights/infrastructure/analytics_api.dart';
import '../../features/insights/presentation/insights_view_model.dart';
import '../../features/journal/application/create_journal_entry_use_case.dart';
import '../../features/journal/application/delete_journal_entry_use_case.dart';
import '../../features/journal/application/get_journal_entries_use_case.dart';
import '../../features/journal/application/get_journal_entry_use_case.dart';
import '../../features/journal/application/get_recent_entries_use_case.dart';
import '../../features/journal/application/update_journal_entry_use_case.dart';
import '../../features/journal/domain/journal_repository.dart';
import '../../features/journal/infrastructure/journal_api.dart';
import '../../features/journal/infrastructure/journal_repository_impl.dart';
import '../../features/journal/presentation/entry_detail_view_model.dart';
import '../../features/journal/presentation/journal_list_view_model.dart';
import '../../features/journal/presentation/new_entry_view_model.dart';
import '../../features/notifications/application/get_notifications_use_case.dart';
import '../../features/notifications/application/get_unread_count_use_case.dart';
import '../../features/notifications/application/mark_all_notifications_read_use_case.dart';
import '../../features/notifications/application/mark_notification_read_use_case.dart';
import '../../features/notifications/infrastructure/notifications_api.dart';
import '../../features/notifications/presentation/notifications_view_model.dart';
import '../../features/profile/application/delete_account_use_case.dart';
import '../../features/profile/application/get_profile_use_case.dart';
import '../../features/profile/application/update_profile_use_case.dart';
import '../../features/profile/infrastructure/profile_api.dart';
import '../../features/profile/presentation/profile_view_model.dart';
import '../../features/settings/infrastructure/pin_api.dart';
import '../../features/settings/presentation/settings_view_model.dart';
import '../../features/subscriptions/application/get_my_subscription_use_case.dart';
import '../../features/subscriptions/application/get_plans_use_case.dart';
import '../../features/subscriptions/application/start_checkout_use_case.dart';
import '../../features/subscriptions/infrastructure/subscriptions_api.dart';
import '../../features/subscriptions/presentation/plans_view_model.dart';
import '../../features/support/application/create_ticket_use_case.dart';
import '../../features/support/application/get_ticket_use_case.dart';
import '../../features/support/application/get_tickets_use_case.dart';
import '../../features/support/application/send_ticket_message_use_case.dart';
import '../../features/support/infrastructure/support_api.dart';
import '../../features/support/presentation/support_view_model.dart';
import '../../features/support/presentation/ticket_detail_view_model.dart';
import '../../features/today/application/load_today_use_case.dart';
import '../../features/today/presentation/today_view_model.dart';
import '../../features/wellness/application/get_wellness_exercises_use_case.dart';
import '../../features/wellness/infrastructure/wellness_api.dart';
import '../../features/wellness/presentation/wellness_exercises_view_model.dart';
import '../l10n/locale_controller.dart';
import '../network/api_client.dart';
import '../platform/privacy_channel.dart';
import '../storage/app_database.dart';
import '../storage/local_prefs.dart';
import '../storage/token_storage.dart';
import '../theme/theme_controller.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // AI feedback
  getIt.registerLazySingleton<AiFeedbackApi>(() => AiFeedbackApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<SubmitAiFeedbackUseCase>(
      () => SubmitAiFeedbackUseCase(api: getIt<AiFeedbackApi>()));
  getIt.registerLazySingleton<GetMyAiFeedbackUseCase>(
      () => GetMyAiFeedbackUseCase(api: getIt<AiFeedbackApi>()));
  getIt.registerLazySingleton<GetAiFeedbackSummaryUseCase>(
      () => GetAiFeedbackSummaryUseCase(api: getIt<AiFeedbackApi>()));
  getIt.registerFactory<AiFeedbackHistoryViewModel>(() => AiFeedbackHistoryViewModel(
        getMyFeedback: getIt<GetMyAiFeedbackUseCase>(),
        getSummary: getIt<GetAiFeedbackSummaryUseCase>(),
      ));

  // Core
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(tokenStorage: getIt<TokenStorage>()));
  getIt.registerLazySingleton<LocalPrefs>(() => LocalPrefs());
  getIt.registerLazySingleton<ThemeController>(() => ThemeController(prefs: getIt<LocalPrefs>()));
  getIt.registerLazySingleton<LocaleController>(() => LocaleController(prefs: getIt<LocalPrefs>()));
  getIt.registerLazySingleton<PrivacyChannel>(() => PrivacyChannel());

  // Auth
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        api: getIt<AuthApi>(),
        tokenStorage: getIt<TokenStorage>(),
      ));
  getIt.registerLazySingleton<SignInUseCase>(
      () => SignInUseCase(repository: getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignUpUseCase>(
      () => SignUpUseCase(repository: getIt<AuthRepository>()));
  getIt.registerLazySingleton<GoogleAuthUseCase>(
      () => GoogleAuthUseCase(repository: getIt<AuthRepository>()));
  getIt.registerLazySingleton<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(repository: getIt<AuthRepository>()));
  getIt.registerFactory<LoginViewModel>(() => LoginViewModel(
        signIn: getIt<SignInUseCase>(),
        googleAuth: getIt<GoogleAuthUseCase>(),
      ));
  getIt.registerFactory<RegisterViewModel>(
      () => RegisterViewModel(signUp: getIt<SignUpUseCase>()));
  getIt.registerFactory<ForgotPasswordViewModel>(
      () => ForgotPasswordViewModel(forgotPassword: getIt<ForgotPasswordUseCase>()));

  // Profile
  getIt.registerLazySingleton<ProfileApi>(() => ProfileApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<GetProfileUseCase>(
      () => GetProfileUseCase(api: getIt<ProfileApi>()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(api: getIt<ProfileApi>()));
  getIt.registerLazySingleton<DeleteAccountUseCase>(
      () => DeleteAccountUseCase(api: getIt<ProfileApi>()));
  getIt.registerFactory<ProfileViewModel>(() => ProfileViewModel(
        getProfile: getIt<GetProfileUseCase>(),
        updateProfile: getIt<UpdateProfileUseCase>(),
        deleteAccount: getIt<DeleteAccountUseCase>(),
      ));

  // Notifications
  getIt.registerLazySingleton<NotificationsApi>(() => NotificationsApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(api: getIt<NotificationsApi>()));
  getIt.registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(api: getIt<NotificationsApi>()));
  getIt.registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(api: getIt<NotificationsApi>()));
  getIt.registerLazySingleton<MarkAllNotificationsReadUseCase>(
      () => MarkAllNotificationsReadUseCase(api: getIt<NotificationsApi>()));
  // Singleton (not a per-page factory): the Today bell badge and the
  // notifications list share the same unread-count state.
  getIt.registerLazySingleton<NotificationsViewModel>(() => NotificationsViewModel(
        getNotifications: getIt<GetNotificationsUseCase>(),
        getUnreadCount: getIt<GetUnreadCountUseCase>(),
        markRead: getIt<MarkNotificationReadUseCase>(),
        markAllRead: getIt<MarkAllNotificationsReadUseCase>(),
      ));

  // Subscriptions
  getIt.registerLazySingleton<SubscriptionsApi>(() => SubscriptionsApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<GetPlansUseCase>(
      () => GetPlansUseCase(api: getIt<SubscriptionsApi>()));
  getIt.registerLazySingleton<GetMySubscriptionUseCase>(
      () => GetMySubscriptionUseCase(api: getIt<SubscriptionsApi>()));
  getIt.registerLazySingleton<StartCheckoutUseCase>(
      () => StartCheckoutUseCase(api: getIt<SubscriptionsApi>()));
  getIt.registerFactory<PlansViewModel>(() => PlansViewModel(
        getPlans: getIt<GetPlansUseCase>(),
        getMySubscription: getIt<GetMySubscriptionUseCase>(),
        startCheckout: getIt<StartCheckoutUseCase>(),
      ));

  // Settings
  getIt.registerLazySingleton<PinApi>(() => PinApi(client: getIt<ApiClient>()));
  getIt.registerFactory<SettingsViewModel>(() => SettingsViewModel(
        getProfile: getIt<GetProfileUseCase>(),
        pinApi: getIt<PinApi>(),
        getMySubscription: getIt<GetMySubscriptionUseCase>(),
        authRepository: getIt<AuthRepository>(),
        themeController: getIt<ThemeController>(),
        localeController: getIt<LocaleController>(),
        prefs: getIt<LocalPrefs>(),
        privacyChannel: getIt<PrivacyChannel>(),
      ));

  // Support
  getIt.registerLazySingleton<SupportApi>(() => SupportApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<GetTicketsUseCase>(
      () => GetTicketsUseCase(api: getIt<SupportApi>()));
  getIt.registerLazySingleton<GetTicketUseCase>(() => GetTicketUseCase(api: getIt<SupportApi>()));
  getIt.registerLazySingleton<CreateTicketUseCase>(
      () => CreateTicketUseCase(api: getIt<SupportApi>()));
  getIt.registerLazySingleton<SendTicketMessageUseCase>(
      () => SendTicketMessageUseCase(api: getIt<SupportApi>()));
  getIt.registerFactory<SupportViewModel>(() => SupportViewModel(
        getTickets: getIt<GetTicketsUseCase>(),
        createTicket: getIt<CreateTicketUseCase>(),
      ));
  getIt.registerFactory<TicketDetailViewModel>(() => TicketDetailViewModel(
        getTicket: getIt<GetTicketUseCase>(),
        sendMessage: getIt<SendTicketMessageUseCase>(),
      ));

  // Chat
  getIt.registerLazySingleton<ChatApi>(() => ChatApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(api: getIt<ChatApi>()));
  getIt.registerLazySingleton<GetConversationsUseCase>(
      () => GetConversationsUseCase(repository: getIt<ChatRepository>()));
  getIt.registerLazySingleton<GetConversationMessagesUseCase>(
      () => GetConversationMessagesUseCase(repository: getIt<ChatRepository>()));
  getIt.registerLazySingleton<StartConversationUseCase>(
      () => StartConversationUseCase(repository: getIt<ChatRepository>()));
  getIt.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(repository: getIt<ChatRepository>()));
  getIt.registerFactory<ChatViewModel>(() => ChatViewModel(
        getConversations: getIt<GetConversationsUseCase>(),
        getMessages: getIt<GetConversationMessagesUseCase>(),
        startConversation: getIt<StartConversationUseCase>(),
        sendMessage: getIt<SendMessageUseCase>(),
      ));

  // Habits
  getIt.registerLazySingleton<HabitsApi>(() => HabitsApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<HabitsRepository>(
      () => HabitsRepositoryImpl(api: getIt<HabitsApi>()));
  getIt.registerLazySingleton<GetHabitsUseCase>(
      () => GetHabitsUseCase(repository: getIt<HabitsRepository>()));
  getIt.registerLazySingleton<CreateHabitUseCase>(
      () => CreateHabitUseCase(repository: getIt<HabitsRepository>()));
  getIt.registerLazySingleton<DeleteHabitUseCase>(
      () => DeleteHabitUseCase(repository: getIt<HabitsRepository>()));
  getIt.registerLazySingleton<GetHabitLogsUseCase>(
      () => GetHabitLogsUseCase(repository: getIt<HabitsRepository>()));
  getIt.registerLazySingleton<ToggleHabitTodayUseCase>(
      () => ToggleHabitTodayUseCase(repository: getIt<HabitsRepository>()));
  getIt.registerLazySingleton<GetHabitSuggestionsUseCase>(
      () => GetHabitSuggestionsUseCase(repository: getIt<HabitsRepository>()));
  getIt.registerFactory<HabitsViewModel>(() => HabitsViewModel(
        getHabits: getIt<GetHabitsUseCase>(),
        getLogs: getIt<GetHabitLogsUseCase>(),
        createHabit: getIt<CreateHabitUseCase>(),
        deleteHabit: getIt<DeleteHabitUseCase>(),
        toggleToday: getIt<ToggleHabitTodayUseCase>(),
        submitAiFeedback: getIt<SubmitAiFeedbackUseCase>(),
      ));
  getIt.registerFactory<HabitSuggestionsViewModel>(() => HabitSuggestionsViewModel(
        getSuggestions: getIt<GetHabitSuggestionsUseCase>(),
        createHabit: getIt<CreateHabitUseCase>(),
      ));

  // Journal
  getIt.registerLazySingleton<JournalApi>(() => JournalApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<JournalRepository>(
      () => JournalRepositoryImpl(api: getIt<JournalApi>()));
  getIt.registerLazySingleton<GetRecentEntriesUseCase>(
      () => GetRecentEntriesUseCase(repository: getIt<JournalRepository>()));
  getIt.registerLazySingleton<CreateJournalEntryUseCase>(
      () => CreateJournalEntryUseCase(repository: getIt<JournalRepository>()));
  getIt.registerLazySingleton<GetJournalEntriesUseCase>(
      () => GetJournalEntriesUseCase(repository: getIt<JournalRepository>()));
  getIt.registerLazySingleton<GetJournalEntryUseCase>(
      () => GetJournalEntryUseCase(repository: getIt<JournalRepository>()));
  getIt.registerLazySingleton<UpdateJournalEntryUseCase>(
      () => UpdateJournalEntryUseCase(repository: getIt<JournalRepository>()));
  getIt.registerLazySingleton<DeleteJournalEntryUseCase>(
      () => DeleteJournalEntryUseCase(repository: getIt<JournalRepository>()));
  getIt.registerFactory<NewEntryViewModel>(
      () => NewEntryViewModel(createEntry: getIt<CreateJournalEntryUseCase>()));
  getIt.registerFactory<JournalListViewModel>(
      () => JournalListViewModel(getEntries: getIt<GetJournalEntriesUseCase>()));
  getIt.registerFactory<EntryDetailViewModel>(() => EntryDetailViewModel(
        getEntry: getIt<GetJournalEntryUseCase>(),
        updateEntry: getIt<UpdateJournalEntryUseCase>(),
        deleteEntry: getIt<DeleteJournalEntryUseCase>(),
        submitAiFeedback: getIt<SubmitAiFeedbackUseCase>(),
      ));

  // Insights
  getIt.registerLazySingleton<AnalyticsApi>(() => AnalyticsApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<GetDashboardUseCase>(
      () => GetDashboardUseCase(api: getIt<AnalyticsApi>()));
  getIt.registerLazySingleton<ExportReportUseCase>(
      () => ExportReportUseCase(api: getIt<AnalyticsApi>()));
  getIt.registerFactory<InsightsViewModel>(() => InsightsViewModel(
        getDashboard: getIt<GetDashboardUseCase>(),
        getHabits: getIt<GetHabitsUseCase>(),
        exportReport: getIt<ExportReportUseCase>(),
      ));

  // Wellness
  getIt.registerLazySingleton<WellnessApi>(() => WellnessApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<GetWellnessExercisesUseCase>(
      () => GetWellnessExercisesUseCase(api: getIt<WellnessApi>()));
  getIt.registerFactory<WellnessExercisesViewModel>(
      () => WellnessExercisesViewModel(getExercises: getIt<GetWellnessExercisesUseCase>()));

  // Today
  getIt.registerLazySingleton<LoadTodayUseCase>(() => LoadTodayUseCase(
        getProfile: getIt<GetProfileUseCase>(),
        getHabits: getIt<GetHabitsUseCase>(),
        getRecentEntries: getIt<GetRecentEntriesUseCase>(),
        getExercises: getIt<GetWellnessExercisesUseCase>(),
      ));
  getIt.registerFactory<TodayViewModel>(() => TodayViewModel(
        loadToday: getIt<LoadTodayUseCase>(),
        createEntry: getIt<CreateJournalEntryUseCase>(),
      ));
}
