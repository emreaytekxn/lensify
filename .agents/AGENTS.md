# Lensify Workspace Rules

## Auto-Commit and Push
Herhangi bir değişiklik, özellik ekleme veya hata giderme (bug fix) yapıldığında, yapılan tüm bu değişiklikleri otomatik olarak aşağıdaki formatta git'e kaydet (commit) ve origin main'e (GitHub) pushla:

```bash
git add .
git commit -m "Mesaj: Yapılan işlemin kısa bir özeti"
git push
```
Bu kural Lensify projesindeki tüm görevler tamamlandığında çalıştırılmalıdır.
