using System.Text;
using System.Text.RegularExpressions;

namespace SkuMasterAPI.Application.Services
{
    public interface IStringCleaningService
    {
        string CleanText(string? input);
        string CleanToLettersOnly(string? input);
        string CleanSearchTerm(string? searchTerm);
    }

    public class StringCleaningService : IStringCleaningService
    {
        /// <summary>
        /// Remove all spaces and keep only letters (Thai and English)
        /// </summary>
        public string CleanText(string? input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return string.Empty;

            // Remove all spaces first
            var noSpaces = input.Replace(" ", "");

            // Keep only Thai and English letters
            return CleanToLettersOnly(noSpaces);
        }

        /// <summary>
        /// Keep only Thai and English letters, remove all other characters
        /// </summary>
        public string CleanToLettersOnly(string? input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return string.Empty;

            var result = new StringBuilder();

            foreach (char c in input)
            {
                // Check if character is Thai (Unicode range: 0E00-0E7F)
                // or English letter (A-Z, a-z)
                if ((c >= 'A' && c <= 'Z') ||
                    (c >= 'a' && c <= 'z') ||
                    (c >= '\u0E00' && c <= '\u0E7F'))
                {
                    result.Append(c);
                }
            }

            return result.ToString();
        }

        /// <summary>
        /// Clean search term: remove spaces and keep only letters for searching
        /// </summary>
        public string CleanSearchTerm(string? searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return string.Empty;

            // For exact phrase search, we need to preserve the order of characters
            // but remove spaces and keep only letters
            var trimmed = searchTerm.Trim();

            // Remove all spaces and keep only letters while preserving order
            var result = new StringBuilder();
            foreach (char c in trimmed)
            {
                // Check if character is Thai (Unicode range: 0E00-0E7F)
                // or English letter (A-Z, a-z)
                if ((c >= 'A' && c <= 'Z') ||
                    (c >= 'a' && c <= 'z') ||
                    (c >= '\u0E00' && c <= '\u0E7F'))
                {
                    result.Append(c);
                }
            }

            return result.ToString();
        }
    }
}

