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

            var result = new StringBuilder();

            foreach (char c in input)
            {
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

        public string CleanToLettersOnly(string? input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return string.Empty;

            var result = new StringBuilder();

            foreach (char c in input)
            {
                if ((c >= 'A' && c <= 'Z') ||
                    (c >= 'a' && c <= 'z') ||
                    (c >= '\u0E00' && c <= '\u0E7F'))
                {
                    result.Append(c);
                }
            }

            return result.ToString();
        }


        public string CleanSearchTerm(string? searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return string.Empty;

            var trimmed = searchTerm.Trim();

            var result = new StringBuilder();
            foreach (char c in trimmed)
            {
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

