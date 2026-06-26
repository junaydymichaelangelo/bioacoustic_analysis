# Load library yang dibutuhkan
library(stringr)
library(dplyr)
library(readr)
library(fs)

# Set path
lokasi_A <- "D:/BIOAKUSTIK/DETECTOR SPECIES/8_SELECTION FALSE POSITIVE-DETECT/FROM SIAMANG DEP7"
lokasi_B <- "G:/BIOAKUSTIK SUAQ BELIMBING/DEPLOYMENT 8"
lokasi_C <- "D:/BIOAKUSTIK/DETECTOR SPECIES/8_SELECTION FALSE POSITIVE-DETECT/DATASET TRAINING DATA/NEW"

# Baca file .txt dari Lokasi A
txt_file <- list.files(lokasi_A, pattern = "\\.txt$", full.names = TRUE)[1] # Ambil satu file pertama
data <- read_delim(txt_file, delim = "\t", show_col_types = FALSE)

# Ekstrak nama acuan dari kolom 'Begin File' (contoh: "Suaq01_20241230_000000" atau "Suaq 01_20241230_000000")
data <- data %>%
  mutate(
    # Tangkap pola "Suaq" dengan opsional spasi, lalu 1-2 digit angka, lalu tanggal dan waktu
    search_key = str_replace_all(
      str_extract(`Begin File`, "Suaq ?\\d{1,2}_\\d{8}_\\d{6}"),
      " ", ""  # Hilangkan spasi jika ada, agar konsisten jadi seperti "Suaq01_..."
    ),
    tag_folder = str_replace_all(Tag, "\\s+", "_")  # Ganti spasi di tag jadi underscore
  )

# Buat list semua file .wav di Lokasi B
wav_files <- dir(lokasi_B, pattern = "\\.wav$", recursive = TRUE, full.names = TRUE)

# Fungsi untuk menyalin file
copy_matched_file <- function(search_key, tag, original_name) {
  matched <- wav_files[str_detect(basename(wav_files), fixed(search_key))]
  
  if (length(matched) == 0) {
    warning(paste("File tidak ditemukan untuk:", search_key))
    return(NULL)
  }
  
  # Ambil path pertama yang cocok
  source_file <- matched[1]
  dest_folder <- file.path(lokasi_C, tag)
  dir_create(dest_folder)  # Buat folder jika belum ada
  
  # Nama file tujuan sesuai nama file aslinya
  dest_file <- file.path(dest_folder, basename(source_file))
  
  # Copy file
  file_copy(source_file, dest_file, overwrite = TRUE)
  message(paste("✓ File berhasil disalin:", basename(source_file), "→", tag))
}

# Iterasi dan salin file
invisible(
  mapply(copy_matched_file, data$search_key, data$tag_folder, data$`Begin File`)
)
