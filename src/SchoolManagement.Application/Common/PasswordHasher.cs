using System;
using System.Security.Cryptography;

namespace SchoolManagement.Application.Common
{
    public static class PasswordHasher
    {
        private const int IterationCount = 310000;

        public static string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, IterationCount, HashAlgorithmName.SHA256))
            {
                byte[] subkey = pbkdf2.GetBytes(32);
                byte[] outputBytes = new byte[1 + 4 + 4 + 4 + 16 + 32];
                outputBytes[0] = 0x01; // Format V3
                
                // Write PRF (1 = HMAC-SHA256)
                WriteNetworkByteOrder(outputBytes, 1, 1);
                // Write iteration count.
                WriteNetworkByteOrder(outputBytes, 5, IterationCount);
                // Write salt size (16)
                WriteNetworkByteOrder(outputBytes, 9, 16);
                
                Buffer.BlockCopy(salt, 0, outputBytes, 13, 16);
                Buffer.BlockCopy(subkey, 0, outputBytes, 29, 32);
                
                return Convert.ToBase64String(outputBytes);
            }
        }

        public static bool VerifyHashedPassword(string hashedPassword, string password)
        {
            try
            {
                byte[] decodedHashedPassword = Convert.FromBase64String(hashedPassword);
                if (decodedHashedPassword.Length < 61) return false;
                if (decodedHashedPassword[0] != 0x01) return false; // Verify format V3
                
                uint prf = ReadNetworkByteOrder(decodedHashedPassword, 1);
                uint iterCount = ReadNetworkByteOrder(decodedHashedPassword, 5);
                uint saltLength = ReadNetworkByteOrder(decodedHashedPassword, 9);
                
                if (saltLength != 16) return false;
                
                byte[] salt = new byte[16];
                Buffer.BlockCopy(decodedHashedPassword, 13, salt, 0, 16);
                
                int subkeyLength = decodedHashedPassword.Length - 13 - 16;
                if (subkeyLength != 32) return false;
                
                byte[] expectedSubkey = new byte[32];
                Buffer.BlockCopy(decodedHashedPassword, 29, expectedSubkey, 0, 32);
                
                using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, (int)iterCount, HashAlgorithmName.SHA256))
                {
                    byte[] actualSubkey = pbkdf2.GetBytes(32);
                    
                    // FixedTimeEquals is safe against timing attacks
                    return CryptographicOperations.FixedTimeEquals(actualSubkey, expectedSubkey);
                }
            }
            catch
            {
                return false;
            }
        }

        private static void WriteNetworkByteOrder(byte[] buffer, int offset, uint value)
        {
            buffer[offset + 0] = (byte)(value >> 24);
            buffer[offset + 1] = (byte)(value >> 16);
            buffer[offset + 2] = (byte)(value >> 8);
            buffer[offset + 3] = (byte)(value >> 0);
        }

        private static uint ReadNetworkByteOrder(byte[] buffer, int offset)
        {
            return ((uint)(buffer[offset + 0]) << 24)
                | ((uint)(buffer[offset + 1]) << 16)
                | ((uint)(buffer[offset + 2]) << 8)
                | ((uint)(buffer[offset + 3]));
        }
    }
}
