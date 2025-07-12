import BankAccount from "../models/bank_account.js";

export const createOrUpdateBankAccount = async (req, res) => {
    try {
        const { bankName, accountNumber, accountHolder, userId } = req.body;

        if (!userId) {
            return res.status(400).json({ message: "User ID is required" });
        }

        // Cek apakah akun bank sudah ada
        const existingAccount = await BankAccount.findOne({ where: { userId } });

        if (existingAccount) {
            // Update data yang ada
            await BankAccount.update(
                { bankName, accountNumber, accountHolder  },
                { where: { userId } }
            );

            // Ambil kembali data yang diperbarui
            const updatedAccount = await BankAccount.findOne({ where: { userId } });

            return res.status(200).json(updatedAccount);
        }

        // Buat akun baru jika belum ada
        const newAccount = await BankAccount.create({
            userId,
            bankName,
            accountNumber,
            accountHolder 
        });

        return res.status(201).json(newAccount);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const getBankAccountByUserId = async (req, res) => {
    try {
        const { userId } = req.params;

        if (!userId) {
            return res.status(400).json({ message: "User ID is required" });
        }

        // Cari akun bank berdasarkan userId
        const bankAccount = await BankAccount.findOne({ where: { userId } });

        if (!bankAccount) {
            return res.status(404).json({ message: "Bank account not found" });
        }

        return res.status(200).json(bankAccount);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};


export const deleteBankAccount = async (req, res) => {
    try {
        const { userId } = req.params;

        if (!userId) {
            return res.status(400).json({ message: "User ID is required" });
        }

        // Cari dan hapus data rekening berdasarkan userId
        const result = await BankAccount.destroy({ where: { userId } });

        if (result === 0) {
            return res.status(404).json({ message: "Bank account not found" });
        }

        return res.status(200).json({ message: "Bank account deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};