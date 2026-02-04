import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/services/bnb_rules_service.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';

class BnBRules extends StatefulWidget {
  final int motelid;
  final SimpleMotel moteldetails;
  const BnBRules({
    super.key,
    required this.motelid,
    required this.moteldetails,
  });

  @override
  State<BnBRules> createState() => _BnBRulesState();
}

class _BnBRulesState extends State<BnBRules> {
  BnbRule? _bnbRule;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await BnbRulesService.getMotelRules(
        widget.motelid,
        context: context,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response['success'] == true) {
            _bnbRule = response['data'] as BnbRule?;
          } else {
            _errorMessage = response['message'] ?? 'Failed to load rules';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading rules: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: SingleMGAppBar("${widget.moteldetails.motelType} Rules", context: context),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: earthGreen),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: textDark.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: textDark.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadRules,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: earthGreen,
                          foregroundColor: softCream,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _bnbRule == null || _bnbRule!.rules == null || _bnbRule!.rules!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: textDark.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No rules available',
                            style: TextStyle(
                              fontSize: 18,
                              color: textDark.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This motel has not set any house rules yet.',
                            style: TextStyle(
                              fontSize: 14,
                              color: textDark.withOpacity(0.4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRules,
                      color: earthGreen,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(7.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Motel Info Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: earthGreen.withOpacity(0.1),
                                    ),
                                    child: const Icon(
                                      Icons.hotel,
                                      color: earthGreen,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.moteldetails.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textDark,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.moteldetails.streetAddress,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textDark.withOpacity(0.6),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Rules Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: earthGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.rule,
                                    color: earthGreen,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'House Rules',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Rules Content
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: earthGreen.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _bnbRule!.rules!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: textDark,
                                ),
                              ),
                            ),
                            if (_bnbRule!.updatedAt != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Last updated: ${_formatDate(_bnbRule!.updatedAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textDark.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
 