import { useEffect } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
// import axios from 'axios'
import { FaCheckCircle, FaWhatsapp, FaEnvelope } from 'react-icons/fa'
import { format } from 'date-fns';
import PointIcon from "../assets/poin_cs.png";


const InvoicePage = () => {
  const location = useLocation()
  const navigate = useNavigate()
  // const [loading, setLoading] = useState(false)
  // const [error, setError] = useState('')
  // const [success, setSuccess] = useState('')
  
  // Ambil data dari state navigasi
  const { points, price, date, bankName } = location.state || {}
  const transactionDate = date ? new Date(date) : new Date()

  useEffect(() => {
    if (!location.state) {
      navigate('/topup')
    }
  }, [location.state, navigate])

  // const handleConfirm = async () => {
  //   setLoading(true)
  //   try {
  //     // Contoh API call untuk konfirmasi akhir
  //     await axios.post(
  //       '/api/topup/confirm',
  //       { transactionId: location.state?.transactionId },
  //       {
  //         headers: {
  //           Authorization: `Bearer ${localStorage.getItem('token')}`
  //         }
  //       }
  //     )
      
  //     setSuccess('Top Up berhasil dikonfirmasi!')
  //     setTimeout(() => navigate('/topup'), 2000)
  //   } catch (err) {
  //     setError(err.response?.data?.message || 'Gagal mengkonfirmasi Top Up')
  //   } finally {
  //     setLoading(false)
  //   }
  // }

  if (!location.state) return null

  return (
    <div className="max-w-4xl mx-auto p-4 bg-white min-h-screen">
      <div className="text-center mb-8">
        <FaCheckCircle className="text-green-500 text-6xl mx-auto mb-4" />
        <h1 className="text-2xl font-bold">Top Up Berhasil!</h1>
        <p className="text-gray-500">Transaksi Anda telah berhasil diproses</p>
      </div>

      <div className="bg-gray-50 rounded-xl p-6 mb-6">
        <h2 className="text-xl font-bold mb-4">Detail Transaksi</h2>
        
        <div className="space-y-3">
          <div className="flex justify-between">
            <span className="text-gray-600">ID Transaksi:</span>
            <span className="font-medium">#{location.state?.transactionId}</span>
          </div>
          
          <div className="flex justify-between">
            <span className="text-gray-600">Tanggal:</span>
            <span className="font-medium">
              {format(transactionDate, 'dd MMM yyyy - HH:mm')}
            </span>
          </div>
          
          <div className="flex justify-between">
            <span className="text-gray-600">Metode Pembayaran:</span>
            <span className="font-medium">{bankName}</span>
          </div>
        </div>
      </div>

      <div className="bg-gray-50 rounded-xl p-6 mb-6">
        <h2 className="text-xl font-bold mb-4">Detail Poin</h2>
        
        <div className="space-y-3">
          <div className="flex justify-between">
            <span className="text-gray-600">Jumlah Poin:</span>
            <div className="flex items-center">
              <img 
                src={PointIcon}
                alt="Poin" 
                className="w-5 h-5 mr-2" 
              />
              <span className="font-medium">{points}</span>
            </div>
          </div>
          
          <div className="flex justify-between">
            <span className="text-gray-600">Total Pembayaran:</span>
            <span className="font-medium">
              Rp {price.toLocaleString()}
            </span>
          </div>
        </div>
      </div>

      <div className="bg-yellow-50 rounded-xl p-6 mb-6">
        <h2 className="text-xl font-bold mb-4">Instruksi Pembayaran</h2>
        
        <div className="space-y-3 text-sm">
          <p>1. Lakukan transfer ke rekening berikut:</p>
          <div className="bg-white p-4 rounded-lg">
            <p className="font-medium">Bank {bankName}</p>
            <p>Nomor Rekening: 0987 6543 2109</p>
            <p>Atas Nama: PT. Digital Terang Bercahaya</p>
          </div>
          
          <p>2. Setelah transfer, segera konfirmasi pembayaran melalui:</p>
          <div className="flex gap-4">
            <a
              href="https://wa.me/089673751717"
              target="_blank"
              rel="noreferrer"
              className="flex items-center bg-green-600 text-white px-4 py-2 rounded-lg"
            >
              <FaWhatsapp className="mr-2" /> WhatsApp
            </a>
            
            <a
              href="mailto:contact@getsayor.com"
              className="flex items-center bg-blue-600 text-white px-4 py-2 rounded-lg"
            >
              <FaEnvelope className="mr-2" /> Email
            </a>
          </div>
        </div>
      </div>

      <div className="flex gap-4">
        {/* <button
          onClick={() => window.print()}
          className="flex items-center bg-gray-100 px-4 py-2 rounded-lg"
        >
          <FaPrint className="mr-2" /> Cetak Invoice
        </button> */}
        
        {/* <button
          onClick={handleConfirm}
          disabled={loading}
          className="flex-1 bg-green-600 text-white px-4 py-2 rounded-lg disabled:bg-gray-400"
        >
          {loading ? 'Memproses...' : 'Konfirmasi Pembayaran'}
        </button> */}
      </div>

      {/* {error && (
        <div className="mt-4 text-red-500 text-center">{error}</div>
      )}
      
      {success && (
        <div className="mt-4 text-green-500 text-center">{success}</div>
      )} */}
    </div>
  )
}

export default InvoicePage