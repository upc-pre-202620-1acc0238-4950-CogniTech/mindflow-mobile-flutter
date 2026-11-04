import 'package:get_it/get_it.dart';

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
import '../../features/profile/application/get_profile_use_case.dart';
import '../../features/profile/infrastructure/profile_api.dart';
import '../../features/today/application/load_today_use_case.dart';
import '../../features/today/presentation/today_view_model.dart';
import '../network/api_client.dart';
import '../storage/app_database.dart';
import '../storage/token_storage.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Core
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(tokenStorage: getIt<TokenStorage>()));

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

  // Today
  getIt.registerLazySingleton<LoadTodayUseCase>(() => LoadTodayUseCase(
        getProfile: getIt<GetProfileUseCase>(),
        getHabits: getIt<GetHabitsUseCase>(),
        getRecentEntries: getIt<GetRecentEntriesUseCase>(),
      ));
  getIt.registerFactory<TodayViewModel>(() => TodayViewModel(
        loadToday: getIt<LoadTodayUseCase>(),
        createEntry: getIt<CreateJournalEntryUseCase>(),
      ));
}
