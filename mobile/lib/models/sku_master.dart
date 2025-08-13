class SkuMasterList {
  final int skuKey;
  final String skuCode;
  final String skuName;
  final List<String> imageUrls;
  final int? skuPrice;

  SkuMasterList({
    required this.skuKey,
    required this.skuCode,
    required this.skuName,
    required this.imageUrls,
    this.skuPrice,
  });

  factory SkuMasterList.fromJson(Map<String, dynamic> json) {
    return SkuMasterList(
      skuKey: json['skuKey'] ?? 0,
      skuCode: json['skuCode'] ?? '',
      skuName: json['skuName'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      skuPrice: json['skuPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuKey': skuKey,
      'skuCode': skuCode,
      'skuName': skuName,
      'imageUrls': imageUrls,
      'skuPrice': skuPrice,
    };
  }

  // Helper method to check if discontinued
  bool get isDiscontinued => skuName.startsWith('(เลิกขาย)');
}

class SkuMasterDetail {
  final int skuKey;
  final String skuName;
  final List<String> imageUrls;
  final double? width;
  final double? length;
  final double? height;
  final double? weight;

  SkuMasterDetail({
    required this.skuKey,
    required this.skuName,
    required this.imageUrls,
    this.width,
    this.length,
    this.height,
    this.weight,
  });

  factory SkuMasterDetail.fromJson(Map<String, dynamic> json) {
    return SkuMasterDetail(
      skuKey: json['skuKey'] ?? 0,
      skuName: json['skuName'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      width: json['width']?.toDouble(),
      length: json['length']?.toDouble(),
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuKey': skuKey,
      'skuName': skuName,
      'imageUrls': imageUrls,
      'width': width,
      'length': length,
      'height': height,
      'weight': weight,
    };
  }
}

class PaginationResponse<T> {
  final List<T> data;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginationResponse({
    required this.data,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginationResponse(
      data: (json['data'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}

class UpdateSkuMasterRequest {
  final int skuKey;
  final String? skuName;
  final List<int>?
  deleteImageIds; // Deprecated - use deleteImageFileNames instead
  final List<String>? deleteImageFileNames; // New preferred method
  final double? width;
  final double? length;
  final double? height;
  final double? weight;

  UpdateSkuMasterRequest({
    required this.skuKey,
    this.skuName,
    this.deleteImageIds, // Keep for backward compatibility
    this.deleteImageFileNames, // New preferred parameter
    this.width,
    this.length,
    this.height,
    this.weight,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {'SkuKey': skuKey.toString()};

    if (skuName != null && skuName!.isNotEmpty) {
      // Note: String cleaning will be handled by the API
      data['SkuName'] = skuName!;
    }

    // Use fileName-based deletion (preferred)
    if (deleteImageFileNames != null && deleteImageFileNames!.isNotEmpty) {
      for (int i = 0; i < deleteImageFileNames!.length; i++) {
        data['DeleteImageFileNames[$i]'] = deleteImageFileNames![i];
      }
    }

    // Backward compatibility for ID-based deletion
    if (deleteImageIds != null && deleteImageIds!.isNotEmpty) {
      for (int i = 0; i < deleteImageIds!.length; i++) {
        data['DeleteImageIds[$i]'] = deleteImageIds![i].toString();
      }
    }

    if (width != null) data['Width'] = width.toString();
    if (length != null) data['Length'] = length.toString();
    if (height != null) data['Height'] = height.toString();
    if (weight != null) data['Weight'] = weight.toString();

    return data;
  }
}

class UpdateSkuMasterResponse {
  final bool success;
  final String message;
  final String? updatedSkuName;
  final List<String> uploadedImageUrls;
  final List<int> deletedImageIds; // Deprecated
  final List<String> deletedImageFileNames; // New preferred method
  final Map<String, dynamic>? updatedSizeDetails;
  final List<String> warnings;

  UpdateSkuMasterResponse({
    required this.success,
    required this.message,
    this.updatedSkuName,
    required this.uploadedImageUrls,
    required this.deletedImageIds,
    required this.deletedImageFileNames,
    this.updatedSizeDetails,
    required this.warnings,
  });

  factory UpdateSkuMasterResponse.fromJson(Map<String, dynamic> json) {
    return UpdateSkuMasterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      updatedSkuName: json['updatedSkuName'],
      uploadedImageUrls: List<String>.from(json['uploadedImageUrls'] ?? []),
      deletedImageIds: List<int>.from(json['deletedImageIds'] ?? []),
      deletedImageFileNames: List<String>.from(
        json['deletedImageFileNames'] ?? [],
      ),
      updatedSizeDetails: json['updatedSizeDetails'],
      warnings: List<String>.from(json['warnings'] ?? []),
    );
  }
}

class UpdateSkuMasterBasicRequest {
  final String? skuName;
  final int? skuPrice;

  UpdateSkuMasterBasicRequest({this.skuName, this.skuPrice});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (skuName != null) {
      // Note: String cleaning will be handled by the API
      data['skuName'] = skuName;
    }
    if (skuPrice != null) data['skuPrice'] = skuPrice;
    return data;
  }
}
