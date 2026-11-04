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
import '../../features/habits/application/get_habits_use_case.dart';
import '../../features/habits/infrastructure/habits_api.dart';
import '../../features/journal/application/create_journal_entry_use_case.dart';
import '../../features/journal/application/get_recent_entries_use_case.dart';
import '../../features/journal/domain/journal_repository.dart';
import '../../features/journal/infrastructure/journal_api.dart';
import '../../features/journal/infrastructure/journal_repository_impl.dart';
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

  // Habits
  getIt.registerLazySingleton<HabitsApi>(() => HabitsApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<GetHabitsUseCase>(
      () => GetHabitsUseCase(api: getIt<HabitsApi>()));

  // Journal
  getIt.registerLazySingleton<JournalApi>(() => JournalApi(client: getIt<ApiClient>()));
  getIt.registerLazySingleton<JournalRepository>(
      () => JournalRepositoryImpl(api: getIt<JournalApi>()));
  getIt.registerLazySingleton<GetRecentEntriesUseCase>(
      () => GetRecentEntriesUseCase(repository: getIt<JournalRepository>()));
  getIt.registerLazySingleton<CreateJournalEntryUseCase>(
      () => CreateJournalEntryUseCase(repository: getIt<JournalRepository>()));
  getIt.registerFactory<NewEntryViewModel>(
      () => NewEntryViewModel(createEntry: getIt<CreateJournalEntryUseCase>()));

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
