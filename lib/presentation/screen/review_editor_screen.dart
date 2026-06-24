import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation_review.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/provider/review_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

class ReviewEditorScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  final String? reviewId;

  const ReviewEditorScreen({
    super.key,
    required this.accommodationId,
    this.reviewId,
  });

  @override
  ConsumerState<ReviewEditorScreen> createState() => _ReviewEditorScreenState();
}

class _ReviewEditorScreenState extends ConsumerState<ReviewEditorScreen> {
  static const _tripTypes = ['혼자', '연인과', '가족과', '친구와', '출장'];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  late final Future<AccommodationReview?> _initialReview;

  AccommodationReview? _editingReview;
  double _rating = 5;
  String _tripType = '연인과';
  bool _recommended = true;
  bool _initialized = false;
  bool _saving = false;

  bool get _isEditing => widget.reviewId != null;

  @override
  void initState() {
    super.initState();
    _initialReview = widget.reviewId == null
        ? Future.value(null)
        : ref.read(reviewRepositoryProvider).getReview(widget.reviewId!);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accommodationAsync =
        ref.watch(accommodationDetailProvider(widget.accommodationId));

    return FutureBuilder<AccommodationReview?>(
      future: _initialReview,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            appBar: YanoljaAppBar.sub(title: '후기 작성'),
            body: Center(
              child: CircularProgressIndicator(color: YanoljaColors.primary),
            ),
          );
        }
        if (_isEditing && snapshot.data == null) {
          return const Scaffold(
            appBar: YanoljaAppBar.sub(title: '후기 수정'),
            body: Center(child: Text('수정할 후기를 찾을 수 없습니다.')),
          );
        }
        _initialize(snapshot.data);

        return Scaffold(
          backgroundColor: YanoljaColors.surfaceAlt,
          appBar: YanoljaAppBar.sub(
            title: _isEditing ? '후기 수정' : '후기 작성',
            fallbackRoute: '/detail/${widget.accommodationId}/reviews',
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                YanoljaEntrance(
                  child: Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: YanoljaColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                              YanoljaRadius.md,
                            ),
                          ),
                          child: const Icon(
                            Icons.hotel_rounded,
                            color: YanoljaColors.primary,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                accommodationAsync.maybeWhen(
                                  data: (item) => item.name,
                                  orElse: () => '숙소',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: YanoljaColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                '직접 경험한 내용을 솔직하게 알려주세요',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: YanoljaColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _FormSection(
                  title: '이번 숙박은 어떠셨나요?',
                  subtitle: '별을 눌러 전체 만족도를 선택하세요',
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var index = 1; index <= 5; index++)
                            IconButton(
                              tooltip: '$index점',
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() => _rating = index.toDouble());
                              },
                              icon: AnimatedScale(
                                duration: YanoljaMotion.fast,
                                scale: index == _rating ? 1.14 : 1,
                                child: Icon(
                                  index <= _rating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 36,
                                  color: YanoljaColors.star,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _ratingLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _FormSection(
                  title: '누구와 다녀오셨나요?',
                  subtitle: '후기를 보는 여행객에게 도움이 됩니다',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in _tripTypes)
                        ChoiceChip(
                          label: Text(type),
                          selected: _tripType == type,
                          showCheckmark: false,
                          selectedColor: YanoljaColors.textPrimary,
                          backgroundColor: YanoljaColors.surfaceAlt,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            color: _tripType == type
                                ? Colors.white
                                : YanoljaColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            setState(() => _tripType = type);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _FormSection(
                  title: '후기 내용',
                  subtitle: '좋았던 점과 아쉬웠던 점을 구체적으로 남겨주세요',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        maxLength: 40,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration('후기 제목'),
                        validator: (value) {
                          if ((value ?? '').trim().length < 4) {
                            return '제목을 4자 이상 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentController,
                        minLines: 6,
                        maxLines: 10,
                        maxLength: 500,
                        decoration: _inputDecoration(
                          '객실 상태, 위치, 서비스 등 실제 경험을 적어주세요.',
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().length < 20) {
                            return '후기 내용을 20자 이상 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _FormSection(
                  title: '다른 여행객에게 추천하시나요?',
                  subtitle: '추천 여부는 후기 목록에 함께 표시됩니다',
                  child: Material(
                    color: Colors.transparent,
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _recommended,
                      activeThumbColor: YanoljaColors.primary,
                      title: Text(
                        _recommended ? '네, 추천해요' : '아쉬운 점이 있었어요',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                        ),
                      ),
                      secondary: Icon(
                        _recommended
                            ? Icons.thumb_up_alt_rounded
                            : Icons.sentiment_dissatisfied_rounded,
                        color: _recommended
                            ? YanoljaColors.success
                            : YanoljaColors.sale,
                      ),
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _recommended = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: YanoljaColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFB9C6FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? '수정 완료' : '후기 등록',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _initialize(AccommodationReview? review) {
    if (_initialized) return;
    _initialized = true;
    _editingReview = review;
    if (review != null) {
      _titleController.text = review.title;
      _commentController.text = review.comment;
      _rating = review.rating;
      _tripType = review.tripType;
      _recommended = review.recommended;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider);
    if (user == null) {
      context.push('/login');
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final review = _editingReview?.copyWith(
          title: _titleController.text.trim(),
          comment: _commentController.text.trim(),
          rating: _rating,
          tripType: _tripType,
          recommended: _recommended,
          updatedAt: now,
        ) ??
        AccommodationReview(
          id: 'review_${now.microsecondsSinceEpoch}',
          accommodationId: widget.accommodationId,
          authorId: user.email,
          authorName: user.displayName,
          title: _titleController.text.trim(),
          comment: _commentController.text.trim(),
          rating: _rating,
          tripType: _tripType,
          recommended: _recommended,
          createdAt: now,
          updatedAt: now,
        );

    try {
      await ref.read(reviewActionsProvider).save(review);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      YanoljaToast.show(
        context,
        _isEditing ? '후기를 수정했어요' : '후기를 등록했어요',
        icon: Icons.rate_review_rounded,
      );
      context.pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _ratingLabel {
    return switch (_rating.round()) {
      5 => '최고예요',
      4 => '만족해요',
      3 => '괜찮아요',
      2 => '아쉬워요',
      _ => '별로예요',
    };
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: YanoljaColors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        borderSide: const BorderSide(
          color: YanoljaColors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: YanoljaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
