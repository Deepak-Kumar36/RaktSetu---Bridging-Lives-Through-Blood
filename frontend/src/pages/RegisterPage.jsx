import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { registerUser } from '../services/authService';
import logo from '../assets/logo.png';

function RegisterPage() {
    const [form, setForm] = useState({
        name: '',
        email: '',
        password: '',
        phone: '',
        role: 'Donor',
    });
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    const [loading, setLoading] = useState(false);

    const navigate = useNavigate();

    const handleChange = (e) => {
        setForm({ ...form, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setSuccess('');
        setLoading(true);

        try {
            await registerUser(form);
            setSuccess('Registration successful! Redirecting to login...');
            setTimeout(() => navigate('/login'), 1500);
        } catch (err) {
            setError(err.response?.data?.message || 'Registration failed. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div
            className="d-flex align-items-center justify-content-center py-5"
            style={{ background: 'linear-gradient(135deg, #fff5f5 0%, #ffe3e3 100%)', minHeight: '100vh' }}
        >
            <div className="bg-white rounded-4 p-5 shadow-sm" style={{ width: '440px' }}>
                <div className="text-center mb-4">
                    <a href="/">
                        <img src={logo} alt="RaktSetu" style={{ width: '60px' }} />
                    </a>
                    <h4 className="fw-bold mt-2" style={{ color: 'var(--brand-red)' }}>Create Account</h4>
                    <p className="text-muted" style={{ fontSize: '0.9rem' }}>Join RaktSetu and start saving lives</p>
                </div>

                {error && <div className="alert alert-danger py-2" style={{ fontSize: '0.85rem' }}>{error}</div>}
                {success && <div className="alert alert-success py-2" style={{ fontSize: '0.85rem' }}>{success}</div>}

                <form onSubmit={handleSubmit}>
                    <div className="mb-3">
                        <label className="form-label">Full Name</label>
                        <input
                            type="text"
                            name="name"
                            className="form-control"
                            value={form.name}
                            onChange={handleChange}
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Email</label>
                        <input
                            type="email"
                            name="email"
                            className="form-control"
                            value={form.email}
                            onChange={handleChange}
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Password</label>
                        <input
                            type="password"
                            name="password"
                            className="form-control"
                            value={form.password}
                            onChange={handleChange}
                            minLength={6}
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Phone</label>
                        <input
                            type="tel"
                            name="phone"
                            className="form-control"
                            value={form.phone}
                            onChange={handleChange}
                        />
                    </div>
                    <div className="mb-4">
                        <label className="form-label">I want to register as</label>
                        <select
                            name="role"
                            className="form-select"
                            value={form.role}
                            onChange={handleChange}
                        >
                            <option value="Donor">Donor</option>
                            <option value="Patient">Patient</option>
                        </select>
                    </div>
                    <button type="submit" className="btn btn-danger w-100 fw-semibold" disabled={loading}>
                        {loading ? 'Creating Account...' : 'Register'}
                    </button>
                </form>

                <p className="text-center text-muted mt-4 mb-0" style={{ fontSize: '0.85rem' }}>
                    Already have an account? <a href="/login" className="text-danger fw-semibold">Login</a>
                </p>
                <p className="text-center mt-2 mb-0" style={{ fontSize: '0.8rem' }}>
                    <a href="/" className="text-muted text-decoration-none">← Back to Home</a>
                </p>
            </div>
        </div>
    );
}

export default RegisterPage;