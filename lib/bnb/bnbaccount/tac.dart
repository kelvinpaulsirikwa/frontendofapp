import 'package:bnbfrontendflutter/models/terms_of_service_model.dart';
import 'package:bnbfrontendflutter/services/terms_service.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:flutter/material.dart';

class TermsAndCondition extends StatefulWidget {
  const TermsAndCondition({super.key});

  @override
  State<TermsAndCondition> createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  TermsOfServiceModel? _terms;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await TermsService.getActiveTerms(context: context);

      if (response['success'] == true) {
        setState(() {
          _terms = response['data'] != null
              ? TermsOfServiceModel.fromJson(
                  Map<String, dynamic>.from(response['data']),
                )
              : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load terms';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading terms: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmSand,
      appBar: SingleMGAppBar(
        'Terms and Conditions',
        context: context,
        isTitleCentered: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: earthGreen))
          : _errorMessage != null
              ? Center(
                  child: ErrorContent(
                          message: _errorMessage!,
                          color: textLight.withOpacity(0.7),
                          onRetry: _loadTerms,
                        ),  )
              : _terms == null
                  ? ErrorContent(
                          message: 'Not found',
                          color: deepTerracotta,
                          onRetry: _loadTerms,
                        ) 
                  : RefreshIndicator(
                      onRefresh: _loadTerms,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: textDark.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _terms!.title,
                                    style: const TextStyle(
                                      color: textDark,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (_terms!.createdBy != null ||
                                      _terms!.updatedAt != null) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (_terms!.createdBy != null)
                                          Text(
                                            'By ${_terms!.createdBy!.username}',
                                            style: const TextStyle(
                                              color: textLight,
                                              fontSize: 13,
                                            ),
                                          ),
                                        if (_terms!.createdBy != null &&
                                            _terms!.updatedAt != null)
                                          const Text(
                                            ' • ',
                                            style: TextStyle(
                                              color: textLight,
                                              fontSize: 13,
                                            ),
                                          ),
                                        if (_terms!.updatedAt != null)
                                          Text(
                                            _formatDate(_terms!.updatedAt!),
                                            style: const TextStyle(
                                              color: textLight,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  Text(
                                    _terms!.content,
                                    style: const TextStyle(
                                      color: textDark,
                                      fontSize: 15,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}