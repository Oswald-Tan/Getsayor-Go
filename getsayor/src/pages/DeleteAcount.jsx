// import { useState } from "react";
import {
  Trash2,
  Mail,
  Clock,
  Shield,
  AlertTriangle,
  CheckCircle,
} from "lucide-react";

const DeleteAccountPage = () => {
//   const [email, setEmail] = useState("");
//   const [showConfirmation, setShowConfirmation] = useState(false);

//   const handleEmailClick = () => {
//     const subject = encodeURIComponent("Delete Account Request");
//     const body = encodeURIComponent(`Hello,

// I would like to permanently delete my account and all associated personal data.

// My registered email/phone: ${
//       email || "[Please enter your registered email or phone number]"
//     }

// Please process this request according to your data deletion policy.

// Thank you.`);

//     window.location.href = `mailto:oswaldtanlee44@gmail.com?subject=${subject}&body=${body}`;
//   };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-6">
            <Trash2 className="w-8 h-8 text-red-600" />
          </div>
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Delete Your Account
          </h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            We&apos;re sorry to see you go. If you&apos;d like to permanently
            delete your account and personal data, please follow the
            instructions below.
          </p>
        </div>

        {/* Main Content */}
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden">
          {/* Warning Banner */}
          <div className="bg-red-50 border-l-4 border-red-400 p-6">
            <div className="flex items-start">
              <AlertTriangle className="w-6 h-6 text-red-400 mt-0.5 mr-3 flex-shrink-0" />
              <div>
                <h3 className="text-lg font-semibold text-red-800 mb-2">
                  Important Notice
                </h3>
                <p className="text-red-700">
                  This action is permanent and cannot be undone. All your data
                  will be deleted according to our data retention policy.
                </p>
              </div>
            </div>
          </div>

          {/* Instructions */}
          <div className="p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
              <Mail className="w-6 h-6 mr-3 text-blue-600" />
              How to Delete Your Account
            </h2>

            <div className="space-y-6">
              <div className="bg-blue-50 rounded-lg p-6">
                <h3 className="font-semibold text-blue-900 mb-4">
                  Follow these steps:
                </h3>
                <ol className="space-y-4">
                  <li className="flex items-start">
                    <span className="flex-shrink-0 w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-semibold mr-4">
                      1
                    </span>
                    <div>
                      <p className="text-gray-700">
                        <strong>Send an email</strong> to{" "}
                        <span className="font-mono bg-gray-100 px-2 py-1 rounded text-blue-600">
                          support@getsayor.com
                        </span>
                      </p>
                      <p className="text-gray-600 mt-1">
                        Use the subject line:{" "}
                        <span className="font-mono bg-gray-100 px-2 py-1 rounded">
                          &quot;Delete Account Request&quot;
                        </span>
                      </p>
                    </div>
                  </li>
                  <li className="flex items-start">
                    <span className="flex-shrink-0 w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-semibold mr-4">
                      2
                    </span>
                    <div>
                      <p className="text-gray-700">
                        <strong>
                          Include your registered email address or phone number
                        </strong>{" "}
                        in the email body
                      </p>
                    </div>
                  </li>
                  <li className="flex items-start">
                    <span className="flex-shrink-0 w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-semibold mr-4">
                      3
                    </span>
                    <div>
                      <p className="text-gray-700">
                        <strong>Wait for processing</strong> - Your request will
                        be processed within 7 working days
                      </p>
                    </div>
                  </li>
                </ol>
              </div>

              {/* Email Helper */}
              {/* <div className="bg-gray-50 rounded-lg p-6">
                <h3 className="font-semibold text-gray-900 mb-4">
                  Quick Email Setup
                </h3>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Your registered email (optional - for pre-filling)
                    </label>
                    <input
                      type="text"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="Enter your registered email"
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none transition-colors"
                    />
                  </div>
                  <button
                    onClick={handleEmailClick}
                    className="w-full bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors flex items-center justify-center"
                  >
                    <Mail className="w-5 h-5 mr-2" />
                    Open Email App with Pre-filled Message
                  </button>
                </div>
              </div> */}
            </div>
          </div>
        </div>

        {/* Data Information */}
        <div className="grid md:grid-cols-2 gap-6 mt-8">
          {/* What will be deleted */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center mr-3">
                <Trash2 className="w-5 h-5 text-red-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900">
                What Will Be Deleted
              </h3>
            </div>
            <ul className="space-y-3">
              <li className="flex items-start">
                <CheckCircle className="w-5 h-5 text-red-500 mt-0.5 mr-3 flex-shrink-0" />
                <span className="text-gray-700">
                  Your account information (name, email, phone)
                </span>
              </li>
              <li className="flex items-start">
                <CheckCircle className="w-5 h-5 text-red-500 mt-0.5 mr-3 flex-shrink-0" />
                <span className="text-gray-700">
                  Purchase and transaction history
                </span>
              </li>
              <li className="flex items-start">
                <CheckCircle className="w-5 h-5 text-red-500 mt-0.5 mr-3 flex-shrink-0" />
                <span className="text-gray-700">Referral or point data</span>
              </li>
            </ul>
          </div>

          {/* What we may keep */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center mr-3">
                <Shield className="w-5 h-5 text-amber-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900">
                What We May Keep
              </h3>
            </div>
            <div className="bg-amber-50 rounded-lg p-4 mb-4">
              <p className="text-sm text-amber-800 font-medium">
                If required by law:
              </p>
            </div>
            <ul className="space-y-3">
              <li className="flex items-start">
                <Clock className="w-5 h-5 text-amber-500 mt-0.5 mr-3 flex-shrink-0" />
                <span className="text-gray-700">
                  Invoice or transaction records for up to 6 months, for legal
                  or tax purposes
                </span>
              </li>
            </ul>
          </div>
        </div>

        {/* Processing Time */}
        <div className="mt-8 bg-white rounded-xl shadow-lg p-6">
          <div className="flex items-center justify-center text-center">
            <Clock className="w-6 h-6 text-blue-600 mr-3" />
            <div>
              <h3 className="text-lg font-semibold text-gray-900">
                Processing Time
              </h3>
              <p className="text-gray-600 mt-1">
                Your deletion request will be processed within{" "}
                <strong>7 working days</strong> of receipt
              </p>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-12 text-center">
          <p className="text-gray-500 text-sm">
            Need help? Contact us at{" "}
            <a
              href="mailto:support@yourdomain.com"
              className="text-blue-600 hover:underline"
            >
              support@getsayor.com
            </a>
          </p>
        </div>
      </div>
    </div>
  );
};

export default DeleteAccountPage;
