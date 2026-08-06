class AppLocalizations {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      // General
      'cancel': 'Cancel',
      'save': 'Save',
      'done': 'Done',
      'share': 'Share',
      'delete': 'Delete',
      'move': 'Move',
      'scan': 'Scan',
      
      // Dashboard & Folders
      'my_documents': 'My Documents',
      'all_documents': 'All Documents',
      'new_folder': 'New Folder',
      'folder_name': 'Folder Name',
      'choose_color': 'Choose Color',
      'create': 'Create',
      'empty_documents': 'No documents yet',
      'empty_documents_desc': 'Tap the button below to\nstart your first scan.',
      'selected': 'Selected',
      'pages': 'Pages',
      
      // Camera & Cropping
      'camera_permission_required': 'Camera permission is required to scan documents.',
      'crop_document': 'Crop Document',
      'gallery': 'Gallery',
      
      // Filters & Editor
      'filter': 'Filter',
      'original': 'Original',
      'black_and_white': 'B&W',
      'grayscale': 'Grayscale',
      'magic_color': 'Magic Color',
      'add_page': 'Add Page',
      'empty_pages': 'No pages in this document.',
      'generating_pdf': 'Generating PDF...',
      'page_n': 'Page {0}',
      'default_scan_title': 'Scan {0}',
    },
    'tr': {
      // General
      'cancel': 'İptal',
      'save': 'Kaydet',
      'done': 'Bitti',
      'share': 'Paylaş',
      'delete': 'Sil',
      'move': 'Taşı',
      'scan': 'Tara',
      
      // Dashboard & Folders
      'my_documents': 'Belgelerim',
      'all_documents': 'Tüm Belgeler',
      'new_folder': 'Yeni Klasör',
      'folder_name': 'Klasör Adı',
      'choose_color': 'Renk Seçin',
      'create': 'Oluştur',
      'empty_documents': 'Henüz belge yok',
      'empty_documents_desc': 'Sağ alttaki butona dokunarak\nilk taramanızı yapın.',
      'selected': 'Seçildi',
      'pages': 'Syf',
      
      // Camera & Cropping
      'camera_permission_required': 'Belge taramak için kamera izni gereklidir.',
      'crop_document': 'Belgeyi Kırp',
      'gallery': 'Galeri',
      
      // Filters & Editor
      'filter': 'Filtrele',
      'original': 'Orijinal',
      'black_and_white': 'Siyah-Beyaz',
      'grayscale': 'Gri Tonlama',
      'magic_color': 'Sihirli Renk',
      'add_page': 'Sayfa Ekle',
      'empty_pages': 'Bu belgede hiç sayfa yok.',
      'generating_pdf': 'PDF Oluşturuluyor...',
      'page_n': 'Sayfa {0}',
      'default_scan_title': 'Tarama {0}',
    }
  };

  static String translate(String languageCode, String key, [List<String>? args]) {
    final langMap = translations[languageCode] ?? translations['en']!;
    String result = langMap[key] ?? key;
    
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        result = result.replaceAll('{$i}', args[i]);
      }
    }
    return result;
  }
}
