import 'package:flutter/material.dart';
import '../../../shared/constants/quiz_questions.dart';
import '../../../shared/constants/test_keys.dart';
import '../../../shared/theme/tonic_colors.dart';
import '../prescription_service.dart';
import 'prescription_card.dart';
import 'question_widget.dart';

/// Quiz screen with 5-question flow.
/// Collects responses and generates a prescription.
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  final void Function(Prescription prescription) onComplete;
  final VoidCallback onSkip;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _responses = {};
  Prescription? _prescription;

  List<QuizQuestion> get _questions => QuizQuestions.questions;
  QuizQuestion get _currentQuestion => _questions[_currentQuestionIndex];
  bool get _isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  bool get _showingResults => _prescription != null;

  void _selectOption(int index) {
    setState(() {
      _responses[_currentQuestion.id] = index;
    });
  }

  void _goToNextQuestion() {
    if (_responses[_currentQuestion.id] == null) return;

    if (_isLastQuestion) {
      // Generate prescription
      final prescription = PrescriptionService.generatePrescription(_responses);
      setState(() {
        _prescription = prescription;
      });
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_showingResults) {
      setState(() {
        _prescription = null;
      });
    } else if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishQuiz() {
    if (_prescription != null) {
      widget.onComplete(_prescription!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.quizScreen,
      backgroundColor: TonicColors.base,
      appBar: AppBar(
        backgroundColor: TonicColors.base,
        elevation: 0,
        leading: _currentQuestionIndex > 0 || _showingResults
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousQuestion,
              )
            : null,
        actions: [
          if (!_showingResults)
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: TonicColors.textMuted,
                    ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _showingResults
              ? _buildResultsView()
              : _buildQuestionView(),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final hasSelection = _responses[_currentQuestion.id] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: QuestionWidget(
              question: _currentQuestion,
              questionNumber: _currentQuestionIndex + 1,
              totalQuestions: _questions.length,
              selectedIndex: _responses[_currentQuestion.id],
              onOptionSelected: _selectOption,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: hasSelection ? _goToNextQuestion : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(_isLastQuestion ? 'See My Prescription' : 'Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your Prescription',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your consultation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TonicColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrescriptionCard(prescription: _prescription!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _finishQuiz,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text('Start Using Tonic'),
          ),
        ),
      ],
    );
  }
}
