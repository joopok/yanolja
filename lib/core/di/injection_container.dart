/// 의존성 주입 컨테이너 (Dependency Injection Container)
/// 
/// Clean Architecture의 모든 계층에서 사용되는 의존성들을 관리합니다.
/// Riverpod Provider를 사용하여 의존성 주입을 처리합니다.
/// 
/// 계층 구조:
/// - Data Sources: 로컬 데이터 소스 (MockAPI, LocalStorage 등)
/// - Repositories: 데이터 접근 계층 구현체
/// - Use Cases: 비즈니스 로직 수행
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data Sources - 데이터를 가져오는 소스 계층
import '../../data/datasources/accommodation_local_datasource.dart';
import '../../data/datasources/booking_local_datasource.dart';
import '../../data/datasources/user_local_datasource.dart';

// Repositories - 데이터 접근 계층 구현체
import '../../data/repositories/accommodation_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';

// Use Cases - 비즈니스 로직 수행 클래스
import '../../domain/usecases/get_accommodations_usecase.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../../domain/usecases/user_usecases.dart';

// ========== Data Source Providers ==========
// 데이터 소스 계층의 Provider들
// 로컬 데이터베이스나 API로부터 데이터를 가져오는 역할

/// 숙소 데이터 소스 Provider
/// 
/// Mock API를 통해 숙소 데이터를 제공합니다.
/// @return AccommodationLocalDataSource 숙소 데이터 소스 인스턴스
final accommodationDataSourceProvider = Provider<AccommodationLocalDataSource>((ref) {
  return AccommodationLocalDataSource();
});

/// 예약 데이터 소스 Provider
/// 
/// 예약 관련 데이터를 관리하는 로컬 데이터 소스입니다.
/// @return BookingLocalDataSource 예약 데이터 소스 인스턴스
final bookingDataSourceProvider = Provider<BookingLocalDataSource>((ref) {
  return BookingLocalDataSource();
});

/// 사용자 데이터 소스 Provider
/// 
/// 사용자 정보와 인증 관련 데이터를 관리하는 로컬 데이터 소스입니다.
/// @return UserLocalDataSource 사용자 데이터 소스 인스턴스
final userDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return UserLocalDataSource();
});

// ========== Repository Providers ==========
// 데이터 접근 계층의 Provider들
// 비즈니스 로직과 데이터 소스 사이를 연결하는 역할

/// 숙소 리포지토리 Provider
/// 
/// 숙소 관련 비즈니스 로직을 처리하는 리포지토리입니다.
/// @param ref Provider 참조
/// @return AccommodationRepositoryImpl 숙소 리포지토리 구현체
final accommodationRepositoryProvider = Provider((ref) {
  return AccommodationRepositoryImpl(ref.watch(accommodationDataSourceProvider));
});

/// 예약 리포지토리 Provider
/// 
/// 예약 관련 비즈니스 로직을 처리하는 리포지토리입니다.
/// @param ref Provider 참조
/// @return BookingRepositoryImpl 예약 리포지토리 구현체
final bookingRepositoryProvider = Provider((ref) {
  return BookingRepositoryImpl(ref.watch(bookingDataSourceProvider));
});

/// 사용자 리포지토리 Provider
/// 
/// 사용자 관련 비즈니스 로직을 처리하는 리포지토리입니다.
/// 로그인, 회원가입, 찜 목록 관리 등의 기능을 포함합니다.
/// @param ref Provider 참조
/// @return UserRepositoryImpl 사용자 리포지토리 구현체
final userRepositoryProvider = Provider((ref) {
  return UserRepositoryImpl(ref.watch(userDataSourceProvider));
});

// ========== Use Case Providers - Accommodation ==========
// 숙소 관련 비즈니스 로직 UseCase Provider들

/// 전체 숙소 목록 조회 UseCase Provider
/// 
/// 모든 숙소 데이터를 가져오는 UseCase입니다.
/// @return GetAccommodationsUseCase 전체 숙소 조회 UseCase
final getAccommodationsUseCaseProvider = Provider((ref) {
  return GetAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

/// 카테고리별 숙소 조회 UseCase Provider
/// 
/// 특정 카테고리(호텔, 펜션, 리조트, 한옥)의 숙소를 필터링하여 조회합니다.
/// @return GetAccommodationsByCategory 카테고리별 숙소 조회 UseCase
final getAccommodationsByCategoryProvider = Provider((ref) {
  return GetAccommodationsByCategory(ref.watch(accommodationRepositoryProvider));
});

/// 숙소 검색 UseCase Provider
/// 
/// 검색어를 기반으로 숙소를 검색하는 UseCase입니다.
/// 이름, 주소, 태그 등을 통해 검색할 수 있습니다.
/// @return SearchAccommodationsUseCase 숙소 검색 UseCase
final searchAccommodationsUseCaseProvider = Provider((ref) {
  return SearchAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

/// 숙소 상세 정보 조회 UseCase Provider
/// 
/// 특정 ID의 숙소 상세 정보를 가져오는 UseCase입니다.
/// @return GetAccommodationDetailUseCase 숙소 상세 조회 UseCase
final getAccommodationDetailUseCaseProvider = Provider((ref) {
  return GetAccommodationDetailUseCase(ref.watch(accommodationRepositoryProvider));
});

/// 인기 숙소 조회 UseCase Provider
/// 
/// isPopular 플래그가 true인 숙소들을 조회합니다.
/// @return GetPopularAccommodationsUseCase 인기 숙소 조회 UseCase
final getPopularAccommodationsUseCaseProvider = Provider((ref) {
  return GetPopularAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

/// 신규 숙소 조회 UseCase Provider
/// 
/// isNew 플래그가 true인 숙소들을 조회합니다.
/// @return GetNewAccommodationsUseCase 신규 숙소 조회 UseCase
final getNewAccommodationsUseCaseProvider = Provider((ref) {
  return GetNewAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

// ========== Use Case Providers - Booking ==========
// 예약 관련 비즈니스 로직 UseCase Provider들

/// 예약 생성 UseCase Provider
/// 
/// 새로운 예약을 생성하는 UseCase입니다.
/// 숙소 ID, 사용자 ID, 체크인/체크아웃 날짜 등을 입력받습니다.
/// @return CreateBookingUseCase 예약 생성 UseCase
final createBookingUseCaseProvider = Provider((ref) {
  return CreateBookingUseCase(ref.watch(bookingRepositoryProvider));
});

/// 사용자 예약 내역 조회 UseCase Provider
/// 
/// 특정 사용자의 모든 예약 내역을 조회하는 UseCase입니다.
/// @return GetUserBookingsUseCase 사용자 예약 조회 UseCase
final getUserBookingsUseCaseProvider = Provider((ref) {
  return GetUserBookingsUseCase(ref.watch(bookingRepositoryProvider));
});

/// 예약 취소 UseCase Provider
/// 
/// 특정 예약을 취소하는 UseCase입니다.
/// 예약 ID를 입력받아 해당 예약을 취소 처리합니다.
/// @return CancelBookingUseCase 예약 취소 UseCase
final cancelBookingUseCaseProvider = Provider((ref) {
  return CancelBookingUseCase(ref.watch(bookingRepositoryProvider));
});

// ========== Use Case Providers - User ==========
// 사용자 관련 비즈니스 로직 UseCase Provider들

/// 이메일 로그인 UseCase Provider
/// 
/// 이메일과 비밀번호를 사용한 로그인 처리 UseCase입니다.
/// @return SignInWithEmailUseCase 이메일 로그인 UseCase
final signInWithEmailUseCaseProvider = Provider((ref) {
  return SignInWithEmailUseCase(ref.watch(userRepositoryProvider));
});

/// 회원가입 UseCase Provider
/// 
/// 새로운 사용자를 등록하는 UseCase입니다.
/// 이메일, 비밀번호, 이름 등의 정보를 입력받습니다.
/// @return SignUpUseCase 회원가입 UseCase
final signUpUseCaseProvider = Provider((ref) {
  return SignUpUseCase(ref.watch(userRepositoryProvider));
});

/// 로그아웃 UseCase Provider
/// 
/// 현재 로그인된 사용자를 로그아웃 처리하는 UseCase입니다.
/// @return SignOutUseCase 로그아웃 UseCase
final signOutUseCaseProvider = Provider((ref) {
  return SignOutUseCase(ref.watch(userRepositoryProvider));
});

/// 현재 사용자 정보 조회 UseCase Provider
/// 
/// 현재 로그인된 사용자의 정보를 가져오는 UseCase입니다.
/// @return GetCurrentUserUseCase 현재 사용자 조회 UseCase
final getCurrentUserUseCaseProvider = Provider((ref) {
  return GetCurrentUserUseCase(ref.watch(userRepositoryProvider));
});

/// 찜한 숙소 목록 조회 UseCase Provider
/// 
/// 사용자가 찜한 숙소 목록을 조회하는 UseCase입니다.
/// @return GetSavedAccommodationsUseCase 찜 목록 조회 UseCase
final getSavedAccommodationsUseCaseProvider = Provider((ref) {
  return GetSavedAccommodationsUseCase(ref.watch(userRepositoryProvider));
});

/// 숙소 찜하기 UseCase Provider
/// 
/// 특정 숙소를 사용자의 찜 목록에 추가하는 UseCase입니다.
/// @return SaveAccommodationUseCase 숙소 찜하기 UseCase
final saveAccommodationUseCaseProvider = Provider((ref) {
  return SaveAccommodationUseCase(ref.watch(userRepositoryProvider));
});

/// 찜한 숙소 제거 UseCase Provider
/// 
/// 사용자의 찜 목록에서 특정 숙소를 제거하는 UseCase입니다.
/// @return RemoveSavedAccommodationUseCase 찜 제거 UseCase
final removeSavedAccommodationUseCaseProvider = Provider((ref) {
  return RemoveSavedAccommodationUseCase(ref.watch(userRepositoryProvider));
});