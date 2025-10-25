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
        /// Clean text while preserving spaces, numbers, and common special characters
        /// </summary>
        public string CleanText(string? input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return string.Empty;

            // Keep spaces, letters, numbers, Thai characters, and common special characters
            var result = new StringBuilder();

            foreach (char c in input)
            {
                // Keep Thai characters, English letters, numbers, spaces, and common special characters
                if ((c >= 'A' && c <= 'Z') ||
                    (c >= 'a' && c <= 'z') ||
                    (c >= '0' && c <= '9') ||
                    (c >= '\u0E00' && c <= '\u0E7F') ||
                    c == ' ' ||  // Keep spaces
                    c == '@' ||  // Keep @
                    c == '#' ||  // Keep #
                    c == '$' ||  // Keep $
                    c == '%' ||  // Keep %
                    c == '&' ||  // Keep &
                    c == '*' ||  // Keep *
                    c == '+' ||  // Keep +
                    c == '-' ||  // Keep -
                    c == '=' ||  // Keep =
                    c == '_' ||  // Keep _
                    c == '.' ||  // Keep .
                    c == ',' ||  // Keep ,
                    c == ':' ||  // Keep :
                    c == ';' ||  // Keep ;
                    c == '!' ||  // Keep !
                    c == '?' ||  // Keep ?
                    c == '(' ||  // Keep (
                    c == ')' ||  // Keep )
                    c == '[' ||  // Keep [
                    c == ']' ||  // Keep ]
                    c == '{' ||  // Keep {
                    c == '}' ||  // Keep }
                    c == '|' ||  // Keep |
                    c == '\\' || // Keep \
                    c == '/' ||  // Keep /
                    c == '<' ||  // Keep <
                    c == '>')    // Keep >
                {
                    result.Append(c);
                }
            }

            return result.ToString();
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
        /// Clean search term: remove spaces and keep letters and numbers for searching
        /// </summary>
        public string CleanSearchTerm(string? searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return string.Empty;

            // For exact phrase search, we need to preserve the order of characters
            // but remove spaces and keep letters and numbers
            var trimmed = searchTerm.Trim();

            // Remove all spaces and keep letters and numbers while preserving order
            var result = new StringBuilder();
            foreach (char c in trimmed)
            {
                // Check if character is Thai (Unicode range: 0E00-0E7F)
                // or English letter (A-Z, a-z) or digit (0-9)
                if ((c >= 'A' && c <= 'Z') ||
                    (c >= 'a' && c <= 'z') ||
                    (c >= '0' && c <= '9') ||
                    (c >= '\u0E00' && c <= '\u0E7F'))
                {
                    result.Append(c);
                }
            }

            return result.ToString();
        }
    }
}

