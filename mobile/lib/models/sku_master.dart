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
      skuKey: json['SkuKey'] ?? 0,
      skuCode: json['SkuCode'] ?? '',
      skuName: json['SkuName'] ?? '',
      imageUrls: List<String>.from(json['ImageUrls'] ?? []),
      skuPrice: json['SkuPrice'],
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
    print('=== SkuMasterDetail.fromJson START ===');
    print('Input JSON: $json');
    print('Width raw: ${json['Width']} (type: ${json['Width'].runtimeType})');
    print(
      'Length raw: ${json['Length']} (type: ${json['Length'].runtimeType})',
    );
    print(
      'Height raw: ${json['Height']} (type: ${json['Height'].runtimeType})',
    );
    print(
      'Weight raw: ${json['Weight']} (type: ${json['Weight'].runtimeType})',
    );

    final width = json['Width']?.toDouble();
    final length = json['Length']?.toDouble();
    final height = json['Height']?.toDouble();
    final weight = json['Weight']?.toDouble();

    print('Width converted: $width (type: ${width.runtimeType})');
    print('Length converted: $length (type: ${length.runtimeType})');
    print('Height converted: $height (type: ${height.runtimeType})');
    print('Weight converted: $weight (type: ${weight.runtimeType})');

    final result = SkuMasterDetail(
      skuKey: json['SkuKey'] ?? 0,
      skuName: json['SkuName'] ?? '',
      imageUrls: List<String>.from(json['ImageUrls'] ?? []),
      width: width,
      length: length,
      height: height,
      weight: weight,
    );

    print(
      'Final result: width=${result.width}, length=${result.length}, height=${result.height}, weight=${result.weight}',
    );
    print('=== SkuMasterDetail.fromJson END ===');

    return result;
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
      data:
          (json['Data'] as List?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      currentPage: json['CurrentPage'] ?? 1,
      pageSize: json['PageSize'] ?? 20,
      totalCount: json['TotalCount'] ?? 0,
      totalPages: json['TotalPages'] ?? 0,
      hasPreviousPage: json['HasPreviousPage'] ?? false,
      hasNextPage: json['HasNextPage'] ?? false,
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
    // Handle both API response formats (capitalized and lowercase)
    final success = json['Success'] ?? json['success'] ?? false;
    final message = json['Message'] ?? json['message'] ?? '';
    final updatedSkuName = json['UpdatedSkuName'] ?? json['updatedSkuName'];

    // Handle uploaded images - API returns list of objects, mobile expects list of URLs
    List<String> uploadedImageUrls = [];
    if (json['UploadedImages'] != null) {
      final uploadedImages = json['UploadedImages'] as List;
      uploadedImageUrls = uploadedImages
          .map((img) => img['ImagePath'] ?? img['ImageName'] ?? '')
          .where((url) => url.isNotEmpty)
          .cast<String>()
          .toList();
    } else if (json['uploadedImageUrls'] != null) {
      uploadedImageUrls = List<String>.from(json['uploadedImageUrls'] ?? []);
    }

    final deletedImageIds = List<int>.from(
      json['DeletedImageIds'] ?? json['deletedImageIds'] ?? [],
    );
    final deletedImageFileNames = List<String>.from(
      json['DeletedImageFileNames'] ?? json['deletedImageFileNames'] ?? [],
    );
    final updatedSizeDetails =
        json['UpdatedSizeDetail'] ?? json['updatedSizeDetails'];
    final warnings = List<String>.from(
      json['Warnings'] ?? json['warnings'] ?? [],
    );

    return UpdateSkuMasterResponse(
      success: success,
      message: message,
      updatedSkuName: updatedSkuName,
      uploadedImageUrls: uploadedImageUrls,
      deletedImageIds: deletedImageIds,
      deletedImageFileNames: deletedImageFileNames,
      updatedSizeDetails: updatedSizeDetails,
      warnings: warnings,
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
